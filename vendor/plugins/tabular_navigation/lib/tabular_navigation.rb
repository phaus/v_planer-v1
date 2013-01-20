NAVIGATION_ENTRIES = [
  ['Kunden',             :clients_path],
  ['Lieferanten',        :distributors_path],
  ['Kategorien',         :categories_path],
  ['Artikel',            :products_path],
  ['Vorgänge',           :rentals_path],
  ['Rechnungen',         :invoices_path],
  ['Mitarbeiter',        [:users_path, :is_company_admin?]],
  ['Administration',     [:admin_path, :is_admin?]]
]

ADMIN_NAVIGATION_ENTRIES = [
  ['Start',          :admin_path],
  ['Firmen',         :admin_companies_path],
  ['Sektionen',      :admin_company_sections_path],
  ['Benutzer',       :admin_users_path]
]

PUBLIC_NAVIGATION_ENTRIES = [
  ['Startseite', '/'],
  ['Login',      :new_user_session_path],
  ['Demo',       'http://planer.rails-apps.de'],
  ['Redmine',    'https://consolving.de/redmine/projects/show/v-planer']
]


module ApplicationHelper
  def main_navigation(opts)
    str = ''
    NAVIGATION_ENTRIES.each do |name, path_options|
      if path_options.is_a?(Array)
        path, prerequisite = path_options
        ok = send prerequisite
      else
        path, ok = path_options, true
      end
      str << navtab(link_to(name, send(path)), :active => name == opts[:active]) if ok
    end
    str.html_safe
  end
  alias navigation main_navigation

  def public_navigation(opts)
    str = ''
    PUBLIC_NAVIGATION_ENTRIES.each do |name, path|
      link_path = path.is_a?(String) ? path : send(path)
      str << navtab(link_to(name, link_path), :active => name == opts[:active])
    end
    str.html_safe
  end

  def navtab(text, options={})
    active = options[:active] ? 'active' : ''
    str = <<-EOS
    <li class="#{active}">
    #{text}
    </li>
    EOS
    str.html_safe
  end

  def aux_navigation(&block)
    <<-EOS
      #{capture(&block) if block_given?}
    EOS
  end
end

