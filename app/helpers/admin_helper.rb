module AdminHelper

  def admin_navigation(opts)
    str = ''
    ADMIN_NAVIGATION_ENTRIES.each do |name, path|
      active = name == opts[:active]
      str << navtab(link_to(name, send(path)), :active => active)
    end
    str
  end
end
