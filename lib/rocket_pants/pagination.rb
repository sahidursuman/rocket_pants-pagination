require 'rocket_pants/pagination/version'

module RocketPants
  #
  # Pagination support for RocketPants
  #
  # Include this module in your RocketPants controllers to add pagination
  # support.
  #
  # @author Alessandro Desantis <desa.alessandro@gmail.com>
  #
  module Pagination
    #
    # Reserved root keys
    #
    RESERVED_PAGINATION_KEYS = [:count, :pagination]

    #
    # Paginates the given relation.
    #
    # @param [ActiveRecord::Relation] the relation to paginate
    # @param [Hash] an options hash for the #paginate method
    #
    # @return [ActiveRecord::Relation] a paginated relation
    #
    def paginate(relation, options = {})
      relation.paginate(options.merge(page: params[:page]))
    end

    #
    # Exposes the given collection with pagination metadata.
    #
    # @param [Hash{Symbol => ActiveRecord::Relation}] a hash with exactly one
    #   element, its key being the root key and its value a paginated relation
    #
    # @raise [ArgumentError] if the hash is malformed
    #
    def expose_with_pagination(hash)
      root_key, collection = extract_pagination_elements_from hash

      response = {}
      response[root_key] = ActiveModel::ArraySerializer.new(collection)
      response[:count] = collection.count
      response[:pagination] = {
        pages: collection.total_pages,
        current: collection.current_page,
        count: collection.count,
        per_page: collection.per_page,
        previous: collection.previous_page,
        next: collection.next_page
      }

      expose response
    end

    #
    # Paginates and exposes the given collection with pagination metadata.
    #
    # Basically, this just calls {#paginate}, then {#expose_with_pagination}.
    #
    # @param [Hash{Symbol => ActiveRecord::Relation}] a hash with exactly one
    #   element, its key being the roto keys and its value a paginated relation
    #
    # @raise [ArgumentError] if the hash is malformed
    #
    def paginate_and_expose(hash)
      root_key, collection = extract_pagination_elements_from hash
      expose_with_pagination "#{root_key}" => paginate(collection)
    end

    private

    def extract_pagination_elements_from(hash)
      validate_pagination_hash! hash
      hash.first
    end

    def validate_pagination_hash!(hash)
      if hash.size != 1
        raise ArgumentError, "the given hash should contain exactly 1 element (#{hash.size} elements)"
      end

      if hash.keys.first.to_sym.in?(RESERVED_PAGINATION_KEYS)
        raise ArgumentError, "the given root key is reserved: #{hash.keys.first}"
      end
    end
  end
end
