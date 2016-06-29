class MatchList < Gtk::ScrolledWindow
  def initialize
    super
    @view = Gtk::TreeView.new
    @view.headers_visible = false
    @view.append_column(Gtk::TreeViewColumn.new('Title', Gtk::CellRendererText.new, 'text' => 0))
    @store = Gtk::ListStore.new(String)
    @view.model = @store

    self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
    self.add(@view)
  end

  def clear
    @store.clear
  end

  def searching
    clear
    item = 'Searching IMDB...'
    @store.set_value(@store.append, 0, item)
  end

  def list=(list)
    clear
    list.each { |item| @store.set_value(@store.append, 0, item) }
  end

  def selected
    @view.selection.signal_connect('changed') do
      yield @view.selection.selected
    end
  end

  def current
    @view.selection.selected[0]
  end

  def disable
    @view.sensitive = false
  end

  def enable
    @view.sensitive = true
  end
end
