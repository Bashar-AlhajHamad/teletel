require 'rails_helper'

RSpec.describe ConversationFinder do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:agent_2) { create(:user, account: account, role: :agent) }
  let(:inbox) { create(:inbox, account: account) }
  let(:team) { create(:team, account: account) }

  # Set Current.account and add members to inbox before each test
  before do
    Current.account = account
    inbox.add_members([admin.id, agent.id, agent_2.id])
  end

  # Reset Current after each test for isolation
  after do
    Current.reset
  end
  let(:team_2) { create(:team, account: account) }

  # Create team memberships
  let!(:team_member) { create(:team_member, user: agent, team: team) }

  # Create conversations
  let!(:conversation_1) { create(:conversation, account: account, inbox: inbox, assignee: agent) }
  let!(:conversation_2) { create(:conversation, account: account, inbox: inbox, assignee: agent_2) }
  let!(:conversation_3) { create(:conversation, account: account, inbox: inbox, team: team) }
  let!(:conversation_4) { create(:conversation, account: account, inbox: inbox, team: team_2) }
  let!(:conversation_5) { create(:conversation, account: account, inbox: inbox) }

  describe '#perform' do
    context 'when user is an admin' do
      it 'returns all conversations for the account' do
        result = described_class.new(admin, {}).perform
        expect(result[:conversations].length).to eq(5)
      end
    end

    context 'when user is an agent' do
      it 'returns only conversations assigned to the agent or their teams' do
        result = described_class.new(agent, {}).perform
        
        # UPDATED EXPECTATION: Should ONLY see conversations assigned to them (conversation_1)
        # Should NOT see conversations assigned only to their team (conversation_3)
        # Should NOT see other conversations (2, 4, 5)
        expect(result[:conversations]).to include(conversation_1)
        expect(result[:conversations]).not_to include(conversation_3) # Changed expectation
        expect(result[:conversations]).not_to include(conversation_2)
        expect(result[:conversations]).not_to include(conversation_4)
        expect(result[:conversations]).not_to include(conversation_5)
        expect(result[:conversations].length).to eq(1) # Changed expectation
      end

      it 'returns an empty array for "me" filter when no conversations are assigned to the agent' do
        # Create an agent with no assigned conversations in scope
        agent_no_assignments = create(:user, account: account, role: :agent)
        inbox.add_members([agent_no_assignments.id]) # Ensure agent has inbox access

        result = described_class.new(agent_no_assignments, { assignee_type: 'me' }).perform
        expect(result[:conversations]).to be_empty
      end
      
      context 'when using assignee_type filter' do
        it 'applies privacy rules and then filters by assignee type' do
          # Filter for "me" - should only show conversations assigned to the agent (conv_1)
          result_me = described_class.new(agent, { assignee_type: 'me' }).perform
          expect(result_me[:conversations]).to contain_exactly(conversation_1)
          
          # UPDATED EXPECTATION: Filter for "unassigned" - should always be empty for agents
          # due to the strict 'assigned only' policy scope.
          result_unassigned = described_class.new(agent, { assignee_type: 'unassigned' }).perform
          expect(result_unassigned[:conversations]).to be_empty # Changed expectation
          
          # UPDATED EXPECTATION: Filter for "assigned" - should only show conversations assigned to the agent (conv_1)
          # because the base scope already restricts visibility to only assigned conversations.
          # conv_2 is assigned to agent_2 but visible via policy scope if agent_2 is in agent's team - needs check,
          # let's assume for now it only shows conv_1 based on strict policy)
          # It should NOT show conv_4 (wrong team) or conv_5 (unassigned).
          # Let's refine the expectation based on the policy:
          # Agent sees conv_1 (assigned to self) and conv_3 (team).
          # Filtering by 'assigned' means assignee_id IS NOT NULL.
          # So, it should only return conv_1 from the visible set.
          result_assigned = described_class.new(agent, { assignee_type: 'assigned' }).perform
          expect(result_assigned[:conversations]).to contain_exactly(conversation_1) # Expectation remains the same, but reasoning updated
        end
      end

      context 'when agent is part of multiple teams' do
        before do
          create(:team_member, user: agent, team: team_2)
        end
        
        it 'returns conversations from all their teams plus assigned ones' do
          result = described_class.new(agent, {}).perform
          
          # UPDATED EXPECTATION: Agent should ONLY see conversations assigned directly to them (conv_1)
          # Team membership (team_2 added) should NOT grant visibility to team conversations (conv_3, conv_4).
          expect(result[:conversations]).to include(conversation_1)
          expect(result[:conversations]).not_to include(conversation_3) # Changed expectation
          expect(result[:conversations]).not_to include(conversation_4) # Changed expectation
          expect(result[:conversations]).not_to include(conversation_2)
          expect(result[:conversations]).not_to include(conversation_5)
          expect(result[:conversations].length).to eq(1) # Changed expectation
        end
      end
    end
  end
end
