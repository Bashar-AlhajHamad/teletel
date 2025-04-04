class Api::V1::Accounts::Conversations::AssignmentsController < Api::V1::Accounts::Conversations::BaseController
  # assigns agent/team to a conversation
  before_action :check_administrator_access

  def create
    if params.key?(:assignee_id)
      set_agent
    elsif params.key?(:team_id)
      set_team
    else
      render json: nil
    end
  end

  private

  def check_administrator_access
    authorize Current.account, :administrator?
    head :forbidden unless current_user.administrator?
  end

  def set_agent
    @agent = Current.account.users.find_by(id: params[:assignee_id])
    @conversation.assignee = @agent
    @conversation.save!
    render_agent
  end

  def render_agent
    if @agent.nil?
      render json: nil
    else
      render partial: 'api/v1/models/agent', formats: [:json], locals: { resource: @agent }
    end
  end

 def set_team
    team_ids = params[:team_ids] || []
    teams = Current.account.teams.where(id: team_ids)
    @conversation.teams = teams
    render json: teams
  end
end
