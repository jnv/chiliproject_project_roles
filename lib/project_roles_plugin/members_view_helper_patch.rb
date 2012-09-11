# -*- encoding : utf-8 -*-
module ProjectRolesPlugin
  module MembersViewHelperPatch

    def load_roles(project)
      #XXX could be handled by Project#available_roles but that would break the chain
      roles = super
      project.local_roles + roles
    end
  end

end
