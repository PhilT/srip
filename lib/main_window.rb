class MainWindow < Gtk::Window
  Thread::abort_on_exception = true
  type_register
  signal_new('ripped', GLib::Signal::RUN_FIRST, nil, nil, String)
  def signal_do_ripped(filename)
  end

  def build
    @info = {}
    @actions = Actions.new
    @owned = Gtk::RadioButton.new('I own this disc')
    @owned.signal_connect('toggled') { update_library_path }
    @rented = Gtk::RadioButton.new(@owned, 'I have rented this disc')

    @start = Gtk::Button.new('Start Rip')
    @start.signal_connect('clicked') do
      @state = nil
      @actions.clear_temp_folder
      @status.push(1, 'Getting disc info...')

      @info_thread = Thread.new do
        @info = @actions.disc_info
        if @info[:error]
          @status.push(1, @info[:error])
        else
          @info = @actions.apply_rules(@info)
          @term.text = clean_title(@info[:name])
          title = @info[:titles].first
          @status.push 1, "Preparing to rip #{title[:filename]}..."

          @rip_thread = Thread.new do
            GLib::Timeout.add(30000) do
              update_progress(title[:size_in_bytes], title[:filename])
              @state != :ripped
            end
            Ripper.new.rip(Actions::TEMP_DIR, title[:id], Actions::MIN_LENGTH)
            @drive.signal_emit('ripped', 0)
          end
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
    @status.push(1, 'Insert disc and press Start Rip to begin')

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
    @add = Gtk::Button.new('Add to Plex')
    @add.sensitive = false
    @add.signal_connect('clicked') { @library.add }
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

    signal_connect('ripped') do |filename|
      @status.push 1, "Completed rip of #{filename}"
      @state = :ripped
      if @add_to.text != ''
        @library.add
      end
    end

    show_all
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

  def update_progress(total_size, filename)
    path = File.join(Actions::TEMP_DIR, filename)

    if @state == nil
      if File.exist?(path)
        @state = :ripping
        @status.push 1, "Ripping #{filename}..."
      end
    elsif @state == :ripping
      @progress.fraction = File.size(path) / total_size.to_f if File.exist?(path)
    end
  end

  def update_library_path
    @actions.set_library_path(@info, @owned.active?)
    @info[:name] = @title.text
    @info[:year] = @year.text

    @library = Library.new(@info, @info[:titles].first[:filename])
    @add_to.text = @library.movie_path
    @add.sensitive = true if @state == :ripped
  end

  def clean_title(title)
    title.gsub(/(dvd|bluray)/i, '').strip
  end
end
