module PostsHelper
  # Сетка как в X.com: зависит от количества фотографий.
  def post_images_grid_class(images_count)
    case images_count
    when 1
      "grid-cols-1"
    when 2
      "grid-cols-2"
    when 3
      "grid-cols-2 grid-rows-2"
    when 4
      "grid-cols-2 grid-rows-2"
    else
      "grid-cols-3 grid-rows-2"
    end
  end

  def post_image_wrapper_class(images_count, index)
    case images_count
    when 3
      index.zero? ? "row-span-2" : ""
    when 5
      index < 2 ? "" : ""
    else
      ""
    end
  end

  def post_image_class(images_count, index)
    base = "block w-full bg-black object-cover"

    size = case images_count
           when 1
             "max-h-[620px] object-contain"
           when 2
             "h-[260px] sm:h-[360px]"
           when 3
             index.zero? ? "h-[340px] sm:h-[430px]" : "h-[169px] sm:h-[214px]"
           when 4
             "h-[170px] sm:h-[240px]"
           when 5, 6
             "h-[150px] sm:h-[205px]"
           else
             "h-[150px] sm:h-[205px]"
           end

    "#{base} #{size}"
  end
end
