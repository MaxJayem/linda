class UserController < ApplicationController

  $messageContexts = []

    def sendMessage

        ### DEFINE CLIENT TOKEN ###

        # RB Casey
        #lient = ApiAiRuby::Client.new(:client_access_token => '6db6184d633a47b280d1edfa4a152c9a', api_lang: 'DE')

        # Experiment 1: Control
        client = ApiAiRuby::Client.new(:client_access_token => 'f853b51cc490411c926df2237967062a', api_lang: 'DE')

        # Experiment 1: Treatment
        #client = ApiAiRuby::Client.new(:client_access_token => '3ccae6b76b5740b2816d571da20f7417, api_lang: 'DE')

        # Send user message if input fields contain text
        if not params[:message_input_field].blank?
            params[:message] = params[:message_input_field]
            response = client.text_request params[:message_input_field], :contexts => $messageContexts
            puts response
        else
            if not params[:quickResponse].blank?
                params[:message] = params[:quickResponse]
                response = client.text_request params[:quickResponse], :contexts => $messageContexts
                puts response
            end
        end

        # For simple text response
        simpleResponses = []

        # For quick reply
        suggestionResponses = []

        # For basic basic_card
        basicCardsTexts = []
        basicCardsLinkTexts = []
        basicCardsLinkUrls = []
        basicCardsImgUrls = []

        # For timeOutDuratio
        @timeoutDuration = 0

        # Process response from Dialogflow
        for i in 0..(response[:result][:fulfillment][:messages]).length-1
          responseType = response[:result][:fulfillment][:messages][i][:type]
          case responseType
          when "simple_response"
            simpleResponses << response[:result][:fulfillment][:messages][i][:textToSpeech]
          # Check for prompts
          when 0
            if response[:result][:fulfillment][:messages][0][:speech] != nil
            simpleResponses << response[:result][:fulfillment][:messages][i][:speech]
            end
          when "suggestion_chips"
            for j in 0..(response[:result][:fulfillment][:messages][i][:suggestions]).length-1
              suggestionResponses << response[:result][:fulfillment][:messages][i][:suggestions][j][:title]
            end
          when "basic_card"
            basicCardsTexts << response[:result][:fulfillment][:messages][i][:formattedText]
            basicCardsLinkTexts << response[:result][:fulfillment][:messages][i][:buttons][0][:title]
            basicCardsLinkUrls << response[:result][:fulfillment][:messages][i][:buttons][0][:openUrlAction][:url]
            basicCardsImgUrls << response[:result][:fulfillment][:messages][i][:image][:url]
          else
            puts "Response type unknown"
          end
        end

        # Empty messageContexts to delete context from previous message
        $messageContexts = []

        # Add contexts from current message to messageContexts variable
        for i in 0..(response[:result][:contexts]).length-1
          $messageContexts << ApiAiRuby::Context.new(response[:result][:contexts][i][:name])
        end

        # Params for view
        params[:simpleResponses] = simpleResponses
        params[:suggestionResponses] = suggestionResponses
        params[:basicCardsTexts] = basicCardsTexts
        params[:basicCardsLinkTexts] = basicCardsLinkTexts
        params[:basicCardsLinkUrls] = basicCardsLinkUrls
        params[:basicCardsImgUrls] = basicCardsImgUrls

        respond_to do |format|
            format.js
        end

    end
end
