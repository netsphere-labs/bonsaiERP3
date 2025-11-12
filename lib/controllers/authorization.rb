# author: Boris Barroso
# email: boriscyber@gmail.com
# module to handle all authorization task
module Controllers::Authorization

  # `current_user` が現在のテナントへのアクセス権を持っているかどうか
  def check_authorization!
    tenant = Apartment::Tenant.current

if USE_SUBDOMAIN
    # このメソッドが呼び出されて, テナントが特定されていないのはオカシイ
    if tenant == "public"
      render plain: "Tenant missing.", status: 403
      return
    end
end

    # TODO: check due_date
    if !current_user || !current_user.active
      render plain: "User missing.", status: 403
      return
    end

    # テナントを確認
if USE_SUBDOMAIN
    org = Organisation.where(tenant: tenant).take
else
    org = Organisation.first
end
    if !org || !Link.where(organisation_id: org.id, user_id: current_user.id, active:true).take
      render plain: "Forbidden to access the organisation.", status: 403
    end
  end

=begin    
      flash[:alert] = "Por favor ingrese."
        redirect_to new_session_url(subdomain: 'app'), allow_other_host: true and return
      elsif !current_user.present?# || current_organisation.dued_with_extension? || !authorized_user?
        redir = request.referer.present? ? :back : home_path

        if request.xhr?
          render plain: '<div class="alert alert-warning flash"><h4 class="n">Usted no tiene los privilegios para ver esta página</h4><div>'
        else
          flash[:alert] = "Usted ha sido redireccionado por que no tiene suficientes privilegios."
          redirect_to redir and return
        end
=end


    def valid_organisation_date?
      (current_organisation.due_on + 3.days) < today
    rescue
      false
    end

    def today
      Date.today
    end

    def check_current_user!
      unless current_user.present?
        flash[:alert] = "Por favor ingrese."
        redirect_to new_session_url(subdomain: 'app') and return
      end
    end

    # Checks the white list for controllers
    def authorized_user?
      role = user_with_role.role
      unless role
        request.env["HTTP_REFERER"] = logout_path
        return false
      end

      h = send(:"#{role}_hash")

      if h[controller_sym].is_a?(Hash)
        h[controller_sym][action_sym]
      else
        !!h[controller_sym]
      end
    end

    #Hashes of priviledges
    def admin_hash
      {
        organisation_updates: true,
        admin_users: true,
        configurations: true,
        tests: true,
        stocks: true,
        inventories: true,
        account_ledgers: true,
        banks: true,
        cashes: true,
        staff_accounts: true,
        transferences: true,
        devolution: true,
        payments: true,
        devolutions: true,
        projects: true,
        incomes: true,
        expenses: true,
        stores: true,
        contacts: true,
        staffs: true,
        items: true,
        units: true,
        users: true,
        user_passwords: true,
        dashboard: true,
        export_incomes: true,
        export_expenses: true,
        inventory_ins: true,
        inventory_outs: true,
        incomes_inventory_ins: true,
        incomes_inventory_outs: true,
        expenses_inventory_ins: true,
        expenses_inventory_outs: true,
        tags: true,
        reports: true,
        inventory_transferences: true,
        download: true,
        taxes: true,
        loans: true,
        loan_payments: true,
        movement_details_history: true,
        tag_groups: true,
        batch_payments: true,
        attachments: true,
        loan_ledger_ins: true
      }
    end

    def group_hash
      {
        admin_users: { show: true },
        configurations: { index: true },
        tests: false,
        stocks: true,
        inventories: true,
        account_ledgers: true,
        banks: true,
        cashes: true,
        staff_accounts: true,
        transferences: true,
        devolution: true,
        payments: true,
        devolutions: true,
        projects: true,
        incomes: true,
        expenses: true,
        stores: true,
        contacts: true,
        staffs: false,
        items: true,
        units: true,
        users: true,
        user_passwords: true,
        dashboard: true,
        export_incomes: true,
        export_expenses: true,
        inventory_ins: true,
        inventory_outs: true,
        incomes_inventory_ins: true,
        incomes_inventory_outs: true,
        expenses_inventory_ins: true,
        expenses_inventory_outs: true,
        tags: true,
        reports: true,
        inventory_transferences: true,
        download: true,
        taxes: true,
        loans: true,
        loan_payments: true,
        movement_details_history: true,
        tag_groups: true,
        batch_payments: true,
        attachments: true,
        loan_ledger_ins: false
      }
    end


    def demo_hash
      {
        admin_users: {show: true},
        configurations: {index: true},
        tests: false,
        stocks: true,
        inventories: true,
        account_ledgers: true,
        banks: true,
        cashes: true,
        staff_accounts: true,
        transferences: true,
        devolution: true,
        payments: true,
        devolutions: true,
        projects: true,
        incomes: true,
        expenses: true,
        stores: true,
        contacts: true,
        staffs: false,
        items: true,
        units: true,
        users: { update: false, edit: true, show: true },
        user_passwords: { new: true, create: false },
        dashboard: true,
        export_incomes: true,
        export_expenses: true,
        inventory_ins: true,
        inventory_outs: true,
        incomes_inventory_ins: true,
        incomes_inventory_outs: true,
        expenses_inventory_ins: true,
        expenses_inventory_outs: true,
        tags: true,
        reports: true,
        inventory_transferences: true,
        download: true,
        taxes: true,
        loans: true,
        loan_payments: true,
        movement_details_history: true,
        tag_groups: true,
        batch_payments: true,
        attachments: true,
        loan_ledger_ins: true
      }
    end

    def other_hash
      {
        admin_users: false,
        configurations: false,
        tests: false,
        stocks: true,
        inventory_operations: false,
        inventories: { index: true, show: true, show_movement: true, show_trans: true },
        account_ledgers: {show: true},
        banks: false,
        cashes: false,
        staff_accounts: false,
        devolution: false,
        payments: true,
        projects: false,
        incomes: true,
        expenses: true,
        stores: false,
        contacts: true,
        staffs: false,
        items: { show: true, index: true, search_income: true, search_expense: true },
        units: { show: true, index: true },
        users: true,
        user_passwords: true,
        dashboard: { home: true },
        reports: false,
        incomes_inventory_outs: true,
        tags: true,
        download: true,
        taxes: false,
        loans: false,
        loan_payments: false,
        movement_details_history: true,
        attachments: { create: true, destroy: false },
        loan_ledger_ins: false
      }
    end
end
