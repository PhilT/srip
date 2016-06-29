# settings for testing
#RIPPER_CLASS = MockRipper
#PROGRESS_TIMEOUT = 1000

# settings for production
RIPPER_CLASS = Ripper
PROGRESS_TIMEOUT = 30000

class MainWindow < Gtk::Window
  START_TEXT = 'Start Copying Disc'
  Thread::abort_on_exception = true
  type_register
  signal_new('labelled', GLib::Signal::RUN_FIRST, nil, nil)
  def signal_do_labelled
  end
  signal_new('ripped', GLib::Signal::RUN_FIRST, nil, nil, Integer)
  def signal_do_ripped(title_num)
  end

  def reset(message)
    log message

    @state = nil
    @start.sensitive = true
    @term.text = ''
    @term.sensitive = false
    @title.text = ''
    @year.text = ''
    @disc.value = 0
    @matches.clear
    @add_to.text = ''
    @add.sensitive = false
    @progress.fraction = 0
  end

  def build
    @actions = Actions.new(RIPPER_CLASS)
    @owned = Gtk::RadioButton.new('I own this disc')
    @owned.signal_connect('toggled') { update_library_path }
    @rented = Gtk::RadioButton.new(@owned, 'I have rented this disc')

    @start = Gtk::Button.new(START_TEXT)
    @start.signal_connect('clicked') do
      @info = {}
      @start.sensitive = false
      @actions.clear_temp_folder
      log 'Getting disc label...'
      @label_thread = Thread.new do
        @info = Disc.new.lookup_name(@actions.label)
        @term.text = @info[:name]
        log "Disc label: #{@info[:name]}"
        @term.sensitive = true
        signal_emit('labelled')
      end
    end

    signal_connect('labelled') do
      log 'Getting disc info...'
      @info_thread = Thread.new do
        @info = @actions.disc_info
        log 'disc info retrieved'
        if @info[:error]
          reset(@info[:error])
        else
          @info = @actions.apply_rules(@info)
          log 'Rules applied'
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
    @log = Gtk::TextView.new

    @scroller = Gtk::ScrolledWindow.new
    @scroller.border_width = 5
    @scroller.add(@log)
    @scroller.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

    @titlebar = Gtk::HBox.new(false, 10)
    @title_label = Gtk::Label.new('Title:')
    @title = Gtk::Entry.new
    @year_label = Gtk::Label.new('Year:')
    @year = Gtk::Entry.new
    @disc_label = Gtk::Label.new('Disc:')
    @disc = Gtk::SpinButton.new(0.0, 10.0, 1.0)
    @titlebar.pack_start(@title_label, false, false)
    @titlebar.pack_start(@title, true, true)
    @titlebar.pack_start(@year_label, false, false)
    @titlebar.pack_start(@year, false, true)
    @titlebar.pack_start(@disc_label, false, false)
    @titlebar.pack_start(@disc, false, true)
    [@title, @year, @disc].each {|control| control.signal_connect('changed') { update_library_path } }

    @add_to_bar = Gtk::HBox.new
    @add_to_label = Gtk::Label.new('Will be Added to: ')
    @add_to_label.set_alignment(0, 0.5)
    @add_to = Gtk::Label.new
    @add_to.modify_font(Pango::FontDescription.new('Ubuntu bold 10'))
    @add_to.set_alignment(0, 0.5)
    @add = Gtk::Button.new('Add to Library')
    @add.signal_connect('clicked') { add_to_library }
    @add_to_bar.pack_start(@add_to_label, false, true)
    @add_to_bar.pack_start(@add_to, true, true)
    @add_to_bar.pack_start(@add, false, true)

    @action_bar = Gtk::HBox.new
    @cancel = Gtk::Button.new('Cancel')
    @cancel.signal_connect('clicked') { cancel }
    @action_bar.pack_start(@cancel, false, false)

    @progress = Gtk::ProgressBar.new
    @progress.set_size_request(-1, 20)

    @quit = Gtk::Button.new('Quit')
    @quit.signal_connect('clicked') { Gtk.main_quit }

    @vbox = Gtk::VBox.new
    [@owned, @rented, @start, @searchbar, @matches, @titlebar, @add_to_bar, @action_bar, @progress, @scroller, @quit].each do |control|
      fill = [MatchList, Gtk::ScrolledWindow].include?(control.class)
      @vbox.pack_start(control, fill, true, 5)
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

    @term.signal_connect('activate') do |w, e|
      @search.signal_emit('clicked')
    end

    signal_connect('ripped') do |widget, title_num|
      log "Completed rip of #{count_message(title_num)}"
      @info[:titles][title_num][:ripped] = true
      title_num += 1
      if title_num < @info[:titles].size
        rip_title(title_num)
      else
        if @title.text != '' && @year.text != ''
          add_to_library
        else
          log "Set correct Title and Year and press 'Add to Library"
          enable_add_to_library
        end
        `eject`
      end
    end

    @title.signal_connect('changed') { enable_add_to_library }
    @year.signal_connect('changed') { enable_add_to_library }

    reset("Insert disc and press '#{START_TEXT}' to begin")

    show_all
  end

  def cancel
    [@label_thread, @info_thread, @rip_thread].each { |thread| thread && thread.kill }
    @actions.cancel
    reset('Cancelled operation')
  end

  def all_ripped?
    @info[:titles] && @info[:titles].all?{|title| title[:ripped] }
  end

  def enable_add_to_library
    if @title.text != '' && @year.text != '' && all_ripped?
      @add.sensitive = true
    else
      @add.sensitive = false
    end
  end

  def add_to_library
    warning = @library.add_all
    warning = "(#{warning})" if warning
    reset "#{@library.name} added to library #{warning}"
  end

  def quit
    cancel
    Gtk.main_quit
  end

  def start
    Gtk.main
  end

  private

  def log(message)
    @log.buffer.text = message + "\n" + @log.buffer.text
  end

  def count_message(n)
    "title #{n + 1} of #{@info[:titles].size}."
  end

  def rip_title(title_num)
    title = @info[:titles][title_num]
    log "Preparing to rip #{count_message(title_num)}..."
    GLib::Timeout.add(PROGRESS_TIMEOUT) do
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
    return false unless @rip_thread.alive?
    filesize = title(title_num, :size_in_bytes).to_f
    filename = title(title_num, :filename)
    path = File.join(Actions::TEMP_DIR, filename)

    if title(title_num, :ripped) == nil
      if File.exist?(path)
        @info[:titles][title_num][:ripped] = false
        log "Ripping #{count_message(title_num)}..."
      end
    elsif title(title_num, :ripped) == false
      @progress.fraction = File.size(path) / filesize if File.exist?(path)
    else
      @progress.fraction = 1
    end
    !title(title_num, :ripped)
  end

  def update_library_path
    @actions.set_library_path(@info, @owned.active?)
    @info[:name] = @title.text
    @info[:year] = @year.text
    @info[:disc] = @disc.text

    @library = Library.new(@info)
    @add_to.text = @library.path
  end
end
