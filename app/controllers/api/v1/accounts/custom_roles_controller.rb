class Api::V1::Accounts::CustomRolesController < Api::V1::Accounts::BaseController
  before_action :fetch_custom_role, only: [:show, :update, :destroy]
  before_action :check_authorization
  before_action -> { authorize CustomRole }, only: [:index, :create]
  before_action -> { authorize @custom_role }, only: [:show, :update, :destroy]

  def index
    @custom_roles = Current.account.custom_roles.includes(:permissions)
    render json: @custom_roles.as_json(include: :permissions)
  end
  

  def create
    @custom_role = Current.account.custom_roles.new(permitted_params.except(:permissions))
  
    if @custom_role.save
      update_permissions(@custom_role, params[:custom_role][:permissions] || [])
  
      # Reload permissions before returning
      @custom_role.reload
  
      render json: @custom_role.as_json(include: :permissions), status: :created
    else
      Rails.logger.error "CustomRole creation failed: #{@custom_role.errors.full_messages}"
      render json: { errors: @custom_role.errors.full_messages }, status: :unprocessable_entity
    end
  end  

  def show; end

  def update
    if @custom_role.update(permitted_params.except(:permissions))
      update_permissions(@custom_role, params[:custom_role][:permissions] || [])

      # Reload permissions before returning
      @custom_role.reload

      render json: @custom_role.as_json(include: :permissions), status: :ok
    else
      render json: { errors: @custom_role.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_role.destroy!
    head :ok
  end

  def update_permissions(custom_role, new_permissions)
    # Remove old permissions
    custom_role.custom_role_permissions.destroy_all
  
    # Assign new permissions
    new_permissions.each do |action|
      permission = Permission.find_or_create_by(action: action, controller: "UnknownController")
      
      # Ensure permission is found/created successfully
      if permission.persisted?
        begin
          CustomRolePermission.create!(custom_role: custom_role, permission: permission)
        rescue => e
          Rails.logger.error "Error creating CustomRolePermission: #{e.message}"
        end
      else
        Rails.logger.error "Failed to find or create permission for action: #{action}"
      end
    end
  end  

  private

  def permitted_params
    params.require(:custom_role).permit(:name, :description, permissions: [])
  end

  def fetch_custom_role
    @custom_role = Current.account.custom_roles.find_by(id: params[:id])
  end
end
