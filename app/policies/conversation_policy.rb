class ConversationPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    @account_user.administrator? || @record.account == account
  end

  def show?
    @account_user.administrator? || @record.assignee == user
  end

  def update?
    @account_user.administrator? || @record.assignee == user
  end

  def destroy?
    @account_user.administrator?
  end
  
  class Scope < Scope
    def resolve
      if @account_user.administrator?
        # Administrators can see all conversations
        scope.where(account_id: account.id)
      else
        # NEW RULE: Agents can ONLY see conversations directly assigned to them.
        scope.where(account_id: account.id, assignee_id: user.id)
      end
    end
  end
end