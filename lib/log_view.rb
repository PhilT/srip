class LogView < Gtk::ScrolledWindow
  def initialize
    super
    @view = Gtk::TextView.new
    @view.editable = false
    @view.buffer.create_tag("bold", {"weight" => Pango::WEIGHT_BOLD})
    @view.wrap_mode = Gtk::TextTag::WRAP_WORD

    self.border_width = 5
    add(@view)
    set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
  end

  def info(message, options = {})
    return unless message
    message += "\n" unless message[-1] == "\n"
    start = @view.buffer.start_iter
    if options[:bold]
      @view.buffer.insert(start, message, 'bold')
    else
      @view.buffer.insert(start, message) # Causes GTK tag unknown warning if supplying blank tag
    end
  end
end
