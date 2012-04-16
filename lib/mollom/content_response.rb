class Mollom
  class ContentResponse
    attr_reader :session_id
    
    # An assessment of the content's quality, between 0 and 1; 0 being very low, 1 being high quality if specified in check_content checks
    attr_reader :quality
    
    # An assessment of the content's profanity level, between 0 and 1; 0 being non-profane, 1 being very profane if specified in check_content checks
    attr_reader :profanity
    
    # An assessment of the content's sentiment, between 0 and 1; 0 being a very negative sentiment, 1 being a very positive sentiment if specified in check_content checks
    attr_reader :sentiment
    
    # a list of structs containing pairs of language and confidence values if specified in checkContent checks
    attr_reader :language

    Unknown = 0
    Ham  = 1
    Spam = 2
    Unsure = 3

    # This class should only be initialized from within the +check_content+ command.
    def initialize(hash)
      @hash = hash
      @spam_response = hash["spam"]
      @session_id = hash["session_id"]
      @quality = hash["quality"]
      @profanity = hash["profanity"]
      @sentiment = hash["sentiment"]
      @language = hash["language"]
    end
    
    # Is the content Spam?
    def spam?
      @spam_response == Spam
    end

    # Is the content Ham?
    def ham?
      @spam_response == Ham
    end

    # is Mollom unsure about the content?
    def unsure?
      @spam_response == Unsure
    end

    # is the content unknown?
    def unknown?
      @spam_response == Unknown
    end

    # Returns 'unknown', 'ham', 'unsure' or 'spam', depending on what the content is.
    def to_s
      case @spam_response
      when Unknown 	then 'unknown'
      when Ham 		then 'ham'
      when Unsure 	then 'unsure'
      when Spam 	then 'spam'
      end
    end
    
    # Returns the original hash for testing
    def to_hash
      @hash
    end
  end
end