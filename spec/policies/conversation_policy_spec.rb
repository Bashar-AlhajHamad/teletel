require 'rails_helper'

RSpec.describe ConversationPolicy do
  subject { described_class }

  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:agent_2) { create(:user, account: account, role: :agent) }
  let(:inbox) { create(:inbox, account: account) }
  let(:team) { create(:team, account: account) }
  let(:team_2) { create(:team, account: account) }

  # Set Current.account and add members to inbox before each test
  before do
    Current.account = account
    inbox.add_members([admin.id, agent.id, agent_2.id])
  end

  # Reset Current after each test for isolation
  after do
    Current.reset
  end

  # Create team memberships
  let!(:team_member) { create(:team_member, user: agent, team: team) }

  # Create conversations
  let!(:conversation_1) { create(:conversation, account: account, inbox: inbox, assignee: agent) }
  let!(:conversation_2) { create(:conversation, account: account, inbox: inbox, assignee: agent_2) }
  let!(:conversation_3) { create(:conversation, account: account, inbox: inbox, team: team) }
  let!(:conversation_4) { create(:conversation, account: account, inbox: inbox, team: team_2) }
  let!(:conversation_5) { create(:conversation, account: account, inbox: inbox) }

  permissions :create? do
    context "when user is an admin" do
      let(:user_context) { { user: admin, account: account, account_user: AccountUser.find_by(user_id: admin.id, account_id: account.id) } }

      it "allows to create a conversation" do
        expect(subject).to permit(user_context, Conversation.new(account: account, inbox: inbox))
      end
    end

    context "when user is an agent" do
      let(:user_context) { { user: agent, account: account, account_user: AccountUser.find_by(user_id: agent.id, account_id: account.id) } }

      it "allows to create a conversation" do
        expect(subject).to permit(user_context, Conversation.new(account: account, inbox: inbox))
      end
    end
  end

  permissions :show? do
    context "when user is an admin" do
      let(:user_context) { { user: admin, account: account, account_user: AccountUser.find_by(user_id: admin.id, account_id: account.id) } }

      it "allows to show any conversation" do
        expect(subject).to permit(user_context, conversation_1)
        expect(subject).to permit(user_context, conversation_2)
        expect(subject).to permit(user_context, conversation_3)
        expect(subject).to permit(user_context, conversation_4)
        expect(subject).to permit(user_context, conversation_5)
      end
    end

    context "when user is an agent" do
      let(:user_context) { { user: agent, account: account, account_user: AccountUser.find_by(user_id: agent.id, account_id: account.id) } }

      it "allows to show a conversation if they are assigned to it" do
        expect(subject).to permit(user_context, conversation_1)
      end

      it "does not allow to show a conversation if they are not assigned to it" do
        expect(subject).not_to permit(user_context, conversation_2)
        expect(subject).not_to permit(user_context, conversation_3)
        expect(subject).not_to permit(user_context, conversation_4)
        expect(subject).not_to permit(user_context, conversation_5)
      end
    end
  end

  permissions :update? do
    context "when user is an admin" do
      let(:user_context) { { user: admin, account: account, account_user: AccountUser.find_by(user_id: admin.id, account_id: account.id) } }

      it "allows to update any conversation" do
        expect(subject).to permit(user_context, conversation_1)
        expect(subject).to permit(user_context, conversation_2)
        expect(subject).to permit(user_context, conversation_3)
        expect(subject).to permit(user_context, conversation_4)
        expect(subject).to permit(user_context, conversation_5)
      end
    end

    context "when user is an agent" do
      let(:user_context) { { user: agent, account: account, account_user: AccountUser.find_by(user_id: agent.id, account_id: account.id) } }

      it "allows to update a conversation if they are assigned to it" do
        expect(subject).to permit(user_context, conversation_1)
      end

      it "does not allow to update a conversation if it is assigned to another agent" do
        expect(subject).not_to permit(user_context, conversation_2)
      end

      it "does not allow to update a conversation if it is assigned to a team they are not a member of" do
        expect(subject).not_to permit(user_context, conversation_4)
      end

      it "does not allow to update a conversation if it is unassigned" do
        expect(subject).not_to permit(user_context, conversation_5)
      end
    end
  end

  permissions :destroy? do
    context "when user is an admin" do
      let(:user_context) { { user: admin, account: account, account_user: AccountUser.find_by(user_id: admin.id, account_id: account.id) } }

      it "allows to destroy any conversation" do
        expect(subject).to permit(user_context, conversation_1)
        expect(subject).to permit(user_context, conversation_2)
        expect(subject).to permit(user_context, conversation_3)
        expect(subject).to permit(user_context, conversation_4)
        expect(subject).to permit(user_context, conversation_5)
      end
    end

    context "when user is an agent" do
      let(:user_context) { { user: agent, account: account, account_user: AccountUser.find_by(user_id: agent.id, account_id: account.id) } }

      it "does not allow to destroy any conversation" do
        expect(subject).not_to permit(user_context, conversation_1)
        expect(subject).not_to permit(user_context, conversation_2)
        expect(subject).not_to permit(user_context, conversation_3)
        expect(subject).not_to permit(user_context, conversation_4)
        expect(subject).not_to permit(user_context, conversation_5)
      end
    end
  end

  permissions ".scope" do
    context "when user is an admin" do
      let(:user_context) { { user: admin, account: account, account_user: AccountUser.find_by(user_id: admin.id, account_id: account.id) } }

      it "shows all conversations" do
        scope = Pundit.policy_scope(user_context, account.conversations)
        expect(scope.count).to eq(5)
      end
    end

    context "when user is an agent" do
      let(:user_context) { { user: agent, account: account, account_user: AccountUser.find_by(user_id: agent.id, account_id: account.id) } }

      it "shows only conversations assigned to the agent or their teams" do
        scope = Pundit.policy_scope(user_context, account.conversations)

        # Should see conversations assigned to them (conversation_1)
        # Should see conversations assigned to their team (conversation_3)
        # Should NOT see other conversations (2, 4, 5)
        expect(scope).to include(conversation_1)
        expect(scope).to include(conversation_3)
        expect(scope).not_to include(conversation_2)
        expect(scope).not_to include(conversation_4)
        expect(scope).not_to include(conversation_5)
        expect(scope.count).to eq(2)
      end

      context 'when agent is part of multiple teams' do
        before do
          create(:team_member, user: agent, team: team_2)
        end

        it 'shows conversations from all their teams plus assigned ones' do
          scope = Pundit.policy_scope(user_context, account.conversations)

          # Should see conversations assigned to them (conversation_1)
          # Should see conversations assigned to their teams (conversation_3, conversation_4)
          expect(scope).to include(conversation_1)
          expect(scope).to include(conversation_3)
          expect(scope).to include(conversation_4)
          expect(scope).not_to include(conversation_2)
          expect(scope).not_to include(conversation_5)
          expect(scope.count).to eq(3)
        end
      end
    end
  end
end
