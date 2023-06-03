require 'rest-client'
require 'json'

module ChatGPT
  class Client
    # Initialize the client with the API key
    #
    # @param api_key [String] The API key for the GPT-3 service
    def initialize(api_key)
      @api_key = api_key
      # Base endpoint for the OpenAI API
      @endpoint = 'https://api.openai.com/v1'
    end

    # Prepare headers for the API request
    #
    # @return [Hash] The headers for the API request
    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }
    end

    # Generate completions based on a given prompt
    #
    # @param prompt [String] The prompt to be completed
    # @param params [Hash] Additional parameters for the completion request
    #
    # @return [Hash] The completion results from the API
    def completions(prompt, params = {})
      # Set default parameters
      engine = params[:engine] || 'text-davinci-002'
      max_tokens = params[:max_tokens] || 16
      temperature = params[:temperature] || 0.5
      top_p = params[:top_p] || 1.0
      n = params[:n] || 1

      # Construct the URL for the completion request
      url = "#{@endpoint}/engines/#{engine}/completions"
      
      # Prepare the data for the request
      data = {
        prompt: prompt,
        max_tokens: max_tokens,
        temperature: temperature,
        top_p: top_p,
        n: n
      }
      
      # Make the request to the API
      request_api(url, data)
    end

    private
    # Make a request to the API
    #
    # @param url [String] The URL for the request
    # @param data [Hash] The data to be sent in the request
    # @param method [Symbol] The HTTP method for the request (:post by default)
    #
    # @return [Hash] The response from the API
    #
    # @raise [RestClient::ExceptionWithResponse] If the API request fails
    def request_api(url, data, method = :post)
      begin
        # Execute the request
        response = RestClient::Request.execute(method: method, url: url, payload: data.to_json, headers: headers)
        
        # Parse and return the response body
        JSON.parse(response.body)
      rescue RestClient::ExceptionWithResponse => e
        # Parse the error message from the API response
        error_msg = JSON.parse(e.response.body)['error']['message']
        
        # Raise an exception with the API error message
        raise RestClient::ExceptionWithResponse.new("#{e.message}: #{error_msg} (#{e.http_code})"), nil, e.backtrace
      end
    end
  
  end
end
