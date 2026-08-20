class PaginationSerializer < ActiveModel::Serializer
  attributes :pagination
  def pagination
    object&.page_info ?
    {
      paginated: {
        has_previous: object.page_info.has_previous_page,
        has_next: object.page_info.has_next_page,
        start_cursor: object.page_info.start_cursor,
        end_cursor: object.page_info.end_cursor
      }
    } : {}
  end
end
