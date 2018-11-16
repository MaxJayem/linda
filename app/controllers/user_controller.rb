class UserController < ApplicationController

  $messageContexts = []


    def sendMessage

      puts $globalContexts

        # RB Casey
        #client = ApiAiRuby::Client.new(:client_access_token => '6db6184d633a47b280d1edfa4a152c9a', api_lang: 'DE')

        # Experiment 1: Control
        client = ApiAiRuby::Client.new(:client_access_token => 'f853b51cc490411c926df2237967062a')

        # Experiment 1: Treatment
        #client = ApiAiRuby::Client.new(:client_access_token => '3ccae6b76b5740b2816d571da20f7417')

        if not params[:message_input_field].blank?
            params[:message] = params[:message_input_field]
            response = client.text_request params[:message_input_field], :contexts => $messageContexts
        else
            if not params[:quickResponse].blank?
                params[:message] = params[:quickResponse]
                response = client.text_request params[:quickResponse], :contexts => $messageContexts
            end
        end

        #params[:response] = response[:result][:fulfillment][:messages]
        simpleResponses = []
        suggestionResponses = []

        for i in 0..(response[:result][:fulfillment][:messages]).length-1
            if response[:result][:fulfillment][:messages][i][:type]=="simple_response"
                 simpleResponses << response[:result][:fulfillment][:messages][i][:textToSpeech]
            else
                if response[:result][:fulfillment][:messages][i][:type]=="suggestion_chips"
                    #puts response[:result][:fulfillment][:messages][i][:suggestions]
                    for j in 0..(response[:result][:fulfillment][:messages][i][:suggestions]).length-1
                        #puts response[:result][:fulfillment][:messages][:suggestions]
                        suggestionResponses << response[:result][:fulfillment][:messages][i][:suggestions][j][:title]
                    end
                end
            end
        end

        # Empty messageContexts to delete context from previous message
        puts "messageContexts wird resettet, Länge sollte wieder 0 sein:"
        $messageContexts = []

        # Add contexts from current message to messageContexts variable
        for i in 0..(response[:result][:contexts]).length-1
          $messageContexts << ApiAiRuby::Context.new(response[:result][:contexts][i][:name])
        end

        params[:response] = simpleResponses
        params[:suggestionResponses] = suggestionResponses
        respond_to do |format|
            format.js
        end
    end
end
