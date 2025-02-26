module Public
    module Api
      module V1
        class InvoicesController < ApplicationController
          before_action :validate_authorization_token

          def send_invoice
            # Static account and inbox IDs
            account_id = 1
            inbox_id = 2
  
            # Get mobile number from the request body
            mobile_number = params[:mobile_number]
  
            # Find or create the contact
            contact = find_or_create_contact(account_id, mobile_number)
  
            # Find or create the conversation
           # conversation = find_or_create_conversation(account_id, inbox_id, contact.id)
  
            # Send the invoice message
           # message = send_message(conversation.id, "Hello, this is your invoice")
  
            # Prepare the response
            response = {
              status: "success",
              message: "Invoice sent successfully",
            }
  
            render json: response, status: :ok
          rescue => e
            render json: { status: "error", message: e.message }, status: :unprocessable_entity
          end
  
          private
  
          def validate_authorization_token
            # Define the expected token (you can store this in environment variables)
            expected_token = ENV['ACCOUNTING_SYSTEM_API_TOKEN']
  
            # Get the token from the request headers
            provided_token = request.headers['Authorization']&.split(' ')&.last
  
            # Compare the tokens
            unless provided_token == expected_token
              render json: { status: "error", message: "Unauthorized" }, status: :unauthorized
            end
          end
  
          def find_or_create_contact(account_id, mobile_number)
            contact = Contact.find_by(phone_number: mobile_number, account_id: account_id)
            unless contact
              contact = Contact.create!(
                name: "Customer #{mobile_number}", # Default name
                phone_number: mobile_number,
                account_id: account_id
              )
            end
            contact
          end
  
          def find_or_create_conversation(account_id, inbox_id, contact_id)
            conversation = Conversation.find_by(account_id: account_id, inbox_id: inbox_id, contact_id: contact_id)
            unless conversation
              conversation = Conversation.create!(
                account_id: account_id,
                inbox_id: inbox_id,
                contact_id: contact_id,
                status: :open
              )
            end
            conversation
          end
  
          def send_message(conversation_id, message_content)
            Message.create!(
              content: message_content,
              account_id: 1, # Static account ID
              inbox_id: 11,  # Static inbox ID
              conversation_id: conversation_id,
              message_type: :outgoing
            )
          end
        end
      end
    end
  end