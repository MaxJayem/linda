class UserController < ApplicationController

    def sendMessage

        ### DEFINE CLIENT TOKEN ###

        # RB Casey
        #client = ApiAiRuby::Client.new(:client_access_token => '6db6184d633a47b280d1edfa4a152c9a', api_lang: 'DE')

        # Experiment 1: Control
        client = ApiAiRuby::Client.new(:client_access_token => 'e4fd5be725fa471d9542fc34a41c34db', api_lang: 'DE')

        # Experiment 1: Treatment
        #client = ApiAiRuby::Client.new(:client_access_token => '3ccae6b76b5740b2816d571da20f7417', api_lang: 'DE')

        # Prepare message contexts to be sent to Dialogflow
        messageContextsObjects = []

        if params[:messageContexts].length > 2
          # Parse string to json
          messageContextsString = params[:messageContexts].gsub("&quot;","\"")
          messageContextsString = "{\"contexts\":" + messageContextsString + "}"
          messageContextsJSON = JSON.parse(messageContextsString,:symbolize_names => true)

          # Create context objects
          messageContextsJSON.each do |key, array|
            array.each do |value|
              name = value[:name]
              lifespan = value[:lifespan]
              parameters = value[:parameters]
              currentContext =  ApiAiRuby::Context.new(name, lifespan, parameters)
              messageContextsObjects << currentContext
            end
          end
        end

        # Send user message if input fields contain text
        if not params[:message_input_field].blank?
            params[:message] = params[:message_input_field]
            response = client.text_request params[:message_input_field], :contexts => messageContextsObjects
        else
            if not params[:quickResponse].blank?
                params[:message] = params[:quickResponse]
                response = client.text_request params[:quickResponse], :contexts => messageContextsObjects
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

        # Process contexts received from Dialogflow
        messageContexts = []
        for i in 0..(response[:result][:contexts]).length-1
          messageContexts << response[:result][:contexts][i]
        end
        messageContextsJSON = messageContexts.to_json

        # Params for view
        params[:simpleResponses] = simpleResponses
        params[:suggestionResponses] = suggestionResponses
        params[:basicCardsTexts] = basicCardsTexts
        params[:basicCardsLinkTexts] = basicCardsLinkTexts
        params[:basicCardsLinkUrls] = basicCardsLinkUrls
        params[:basicCardsImgUrls] = basicCardsImgUrls
        params[:messageContexts] = messageContextsJSON

        respond_to do |format|
            format.js
        end

    end
end
