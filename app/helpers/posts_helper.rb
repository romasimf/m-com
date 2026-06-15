module PostsHelper
  def post_media_grid_class(media_count)
    case media_count
    when 1 then "grid-cols-1"
    else "grid-cols-2"
    end
  end

  def post_media_wrapper_class(media_count, index)
    base = "overflow-hidden bg-[#111111]"

    case media_count
    when 3
      index.zero? ? "#{base} row-span-2" : base
    when 5
      index == 4 ? "#{base} col-span-2" : base
    else
      base
    end
  end

  def post_media_size_class(media_count, index)
    case media_count
    when 1
      "max-h-[700px]"
    when 2
      "h-[280px] sm:h-[380px]"
    when 3
      index.zero? ? "h-[360px] sm:h-[480px]" : "h-[178px] sm:h-[238px]"
    when 4
      "h-[190px] sm:h-[280px]"
    when 5
      index == 4 ? "h-[280px] sm:h-[340px]" : "h-[190px] sm:h-[280px]"
    else
      "h-[190px] sm:h-[260px]"
    end
  end

  def post_media_image_class(media_count, index)
    "w-full h-full bg-black object-cover #{post_media_size_class(media_count, index)}"
  end

  def post_media_video_class(media_count, index)
    "w-full h-full bg-black object-cover #{post_media_size_class(media_count, index)}"
  end

  def media_is_video?(attachment)
    attachment.blob.content_type.start_with?("video/")
  end
end