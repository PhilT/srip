class Gui
  def initialize
    @info = {}
    @actions = Actions.new
    @owned = Gtk::RadioButton.new('I own this disc')
    @owned.signal_connect('toggled') { update_library_path }
    @rented = Gtk::RadioButton.new(@owned, 'I have rented this disc')

    @start = Gtk::Button.new('Start Rip')
    @start.signal_connect('clicked') do
      @actions.clear_temp_folder
      @status.push(1, 'Getting disc info')

      @info_thread = Thread.new do
        @info = @actions.disc_info
        @term.text = clean_title(@info[:name])
        if @info[:error]
          @status.push(1, @info[:error])
        else
        end
      end
    end

    @searchbar = Gtk::HBox.new
    @term = Gtk::Entry.new
    @search = Gtk::Button.new('Search IMDB')
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
    @add_to_label.set_alignment(0, 0)
    @add_to = Gtk::Label.new
    @add_to.modify_font(Pango::FontDescription.new('monospace bold 12'))
    @add_to.set_alignment(0, 0)
    @add_to_bar.pack_start(@add_to_label, false, true)
    @add_to_bar.pack_start(@add_to, true, true)

    @quit = Gtk::Button.new('Quit')
    @quit.signal_connect('clicked') { Gtk.main_quit }

    @hbox = Gtk::HBox.new
    @vbox = Gtk::VBox.new
    @vbox.set_size_request(900, -1)
    [@owned, @rented, @start, @searchbar, @matches, @titlebar, @add_to_bar, @quit, @status].each do |control|
      @vbox.pack_start(control, false, true, 5)
    end
    @hbox.pack_start(@vbox, false, true)

    @window = Gtk::Window.new
    @window.add(@hbox)
    @window.signal_connect('delete_event') { false }
    @window.signal_connect('destroy') do
      quit
    end
    @window.border_width = 10
    @window.add_events(Gdk::Event::KEY_PRESS)

    @window.signal_connect('key-press-event') do |w, e|
      key = Gdk::Keyval.to_name(e.keyval)
      quit if key == 'q' && e.state.control_mask?
    end

    @window.show_all
  end

  def quit
    @info_thread.kill if @info_thread
    Gtk.main_quit
  end

  def start
    Gtk.main
    @info_thread.join if @info_thread
  end

  private

  def update_library_path
    @actions.set_library_path(@info, @owned.active?)
    @info[:name] = @title.text
    @info[:year] = @year.text

    @library = Library.new(@info, @info[:titles].first)
    @add_to.text = @library.movie_path
  end

  def clean_title(title)
    title.gsub(/(dvd|bluray)/i, '').strip
  end
end
