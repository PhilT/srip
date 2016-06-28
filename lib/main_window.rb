class MainWindow < Gtk::Window
  START_TEXT = 'Start Copying Disc'
  Thread::abort_on_exception = true
  type_register
  signal_new('ripped', GLib::Signal::RUN_FIRST, nil, nil, Integer)
  def signal_do_ripped(title_num)
  end

  def reset(message)
    @status.push(1, message)

    @info = {}
    @state = nil
    @start.sensitive = true
    @term.text = ''
    @title.text = ''
    @year.text = ''
    @matches.clear
    @add_to.text = ''
    @add.sensitive = false
    @progress.fraction = 0
  end

  def build
    @actions = Actions.new(MockRipper.new)
    @owned = Gtk::RadioButton.new('I own this disc')
    @owned.signal_connect('toggled') { update_library_path }
    @rented = Gtk::RadioButton.new(@owned, 'I have rented this disc')

    @start = Gtk::Button.new(START_TEXT)
    @start.signal_connect('clicked') do
      @start.sensitive = false
      @actions.clear_temp_folder
      @status.push(1, 'Getting disc info...')

      @info_thread = Thread.new do
        @info = @actions.disc_info
        if @info[:error]
          reset(@info[:error])
        else
          @info = @actions.apply_rules(@info)
          @term.text = clean_title(@info[:name])
          rip_title(0)
        end
      end
    end

    @searchbar = Gtk::HBox.new
    @term = Gtk::Entry.new
    @search = Gtk::Button.new('  Search IMDB  ')
    @search.signal_connect('clicked') do
      @matches.disable
      @matches.searching
      Thread.new do
        @actions.search(@term.text, @matches)
        @matches.enable
      end
    end
    @searchbar.pack_start(@term, true, true)
    @searchbar.pack_start(@search, false, true)

    @matches = MatchList.new
    @matches.selected do |item|
      begin
        @title.text, @year.text = item[0].split(/\(|\)/).map(&:strip)
      rescue
      end
    end
    @status = Gtk::Statusbar.new

    @titlebar = Gtk::HBox.new(false, 10)
    @title_label = Gtk::Label.new('Title:')
    @title = Gtk::Entry.new
    @year_label = Gtk::Label.new('Year:')
    @year = Gtk::Entry.new
    @titlebar.pack_start(@title_label, false, false)
    @titlebar.pack_start(@title, true, true)
    @titlebar.pack_start(@year_label, false, false)
    @titlebar.pack_start(@year, false, true)
    @title.signal_connect('changed') { update_library_path }
    @year.signal_connect('changed') { update_library_path }

    @add_to_bar = Gtk::HBox.new
    @add_to_label = Gtk::Label.new('Will be Added to: ')
    @add_to_label.set_alignment(0, 0.5)
    @add_to = Gtk::Label.new
    @add_to.modify_font(Pango::FontDescription.new('monospace bold 12'))
    @add_to.set_alignment(0, 0.5)
    @add = Gtk::Button.new('Add to Library')
    @add.signal_connect('clicked') { add_to_library }
    @add_to_bar.pack_start(@add_to_label, false, true)
    @add_to_bar.pack_start(@add_to, true, true)
    @add_to_bar.pack_start(@add, false, true)

    @quit = Gtk::Button.new('Quit')
    @quit.signal_connect('clicked') { Gtk.main_quit }

    @progress = Gtk::ProgressBar.new

    @vbox = Gtk::VBox.new
    [@owned, @rented, @start, @searchbar, @matches, @titlebar, @add_to_bar, @quit, @status, @progress].each do |control|
      @vbox.pack_start(control, false, true, 5)
    end

    add(@vbox)
    signal_connect('delete_event') { false }
    signal_connect('destroy') do
      quit
    end
    self.border_width = 10
    add_events(Gdk::Event::KEY_PRESS)

    signal_connect('key-press-event') do |w, e|
      key = Gdk::Keyval.to_name(e.keyval)
      quit if key == 'q' && e.state.control_mask?
    end

    signal_connect('ripped') do |widget, title_num|
      filename = @info[:titles][title_num][:filename]
      @status.push 1, "#{count_message(title_num)} Completed rip of #{filename}"
      title_num += 1
      if title_num < @info[:titles].size
        rip_title(title_num)
      else
        @info[:titles][title_num][:ripped] = true
        if @title.text != '' && @year.text != ''
          add_to_library
        else
          @status.push 1, "Set correct Title and Year and press 'Add to Library"
          add.sensitive = true
        end
        `eject`
      end
    end

    reset("Insert disc and press '#{START_TEXT}' to begin")

    show_all
  end

  def add_to_library
    warning = @library.add_all
    warning = "(#{warning})" if warning
    reset "#{@library.current} added to library #{warning}"
  end

  def quit
    @info_thread.kill if @info_thread
    @rip_thread.kill if @rip_thread
    Gtk.main_quit
  end

  def start
    Gtk.main
  end

  private

  def count_message(n)
    "Title #{n + 1} of #{@info[:titles].size}."
  end

  def rip_title(title_num)
    title = @info[:titles][title_num]
    @status.push 1, "#{count_message(title_num)} Preparing to rip #{title[:filename]}..."
    GLib::Timeout.add(30000) do
      update_progress(title_num)
    end

    @rip_thread = Thread.new do
      @actions.rip_disc(title[:id])
      signal_emit('ripped', title_num)
    end
  end

  def title(n, attr)
    @info[:titles][n][attr]
  end

  def update_progress(title_num)
    filesize = title(title_num, :size_in_bytes).to_f
    filename = title(title_num, :filename)
    path = File.join(Actions::TEMP_DIR, filename)

    if title(title_num, :ripped) == nil
      if File.exist?(path)
        @info[:titles][title_num][:ripped] = false
        @status.push 1, "Ripping #{filename}..."
      end
    elsif title(title_num, :ripped) == false
      @progress.fraction = File.size(path) / filesize if File.exist?(path)
    end
    !title(title_num, :ripped)
  end

  def update_library_path
    @actions.set_library_path(@info, @owned.active?)
    @info[:name] = @title.text
    @info[:year] = @year.text

    @library = Library.new(@info, @info[:titles].first[:filename])
    @add_to.text = @library.path
    @add.sensitive = true if @state == :ripped
  end

  def clean_title(title)
    title.gsub(/(dvd|bluray)/i, '').strip
  end
end
