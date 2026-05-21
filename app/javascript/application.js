// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const MAX_POST_IMAGES = 6

function xGridClass(count) {
  if (count === 1) return "grid grid-cols-1 gap-0.5"
  if (count === 2) return "grid grid-cols-2 gap-0.5"
  if (count === 3) return "grid grid-cols-2 grid-rows-2 gap-0.5"
  if (count === 4) return "grid grid-cols-2 grid-rows-2 gap-0.5"
  return "grid grid-cols-3 grid-rows-2 gap-0.5"
}

function xWrapperClass(count, index) {
  let classes = "relative overflow-hidden bg-black"

  if (count === 3 && index === 0) {
    classes += " row-span-2"
  }

  return classes
}

function xImageClass(count, index) {
  const base = "block w-full bg-black object-cover"

  if (count === 1) return `${base} max-h-[620px] object-contain`
  if (count === 2) return `${base} h-[260px] sm:h-[360px]`

  if (count === 3) {
    return index === 0
      ? `${base} h-[340px] sm:h-[430px]`
      : `${base} h-[169px] sm:h-[214px]`
  }

  if (count === 4) return `${base} h-[170px] sm:h-[240px]`

  return `${base} h-[150px] sm:h-[205px]`
}

function setupPostImagePreview() {
  const input = document.getElementById("post-images-input")
  const gallery = document.getElementById("post-images-gallery")
  const counter = document.getElementById("image-preview-counter")
  const removedContainer = document.getElementById("removed-images-container")

  if (!input || !gallery) return
  if (input.dataset.previewReady === "true") return

  input.dataset.previewReady = "true"

  const maxFiles = Number(input.dataset.maxFiles || MAX_POST_IMAGES)
  let pendingFiles = []
  let existingImages = []
  let removedExistingIds = []

  try {
    existingImages = JSON.parse(gallery.dataset.existingImages || "[]").map((image) => ({
      type: "existing",
      id: String(image.id),
      url: image.url
    }))
  } catch (_error) {
    existingImages = []
  }

  function syncFileInput() {
    if (!window.DataTransfer) return

    const dataTransfer = new DataTransfer()
    pendingFiles.forEach((file) => dataTransfer.items.add(file))
    input.files = dataTransfer.files
  }

  function syncRemovedInputs() {
    if (!removedContainer) return

    removedContainer.innerHTML = ""

    removedExistingIds.forEach((id) => {
      const hiddenInput = document.createElement("input")
      hiddenInput.type = "hidden"
      hiddenInput.name = "post[remove_image_ids][]"
      hiddenInput.value = id
      removedContainer.appendChild(hiddenInput)
    })
  }

  function currentItems() {
    const visibleExisting = existingImages.filter((image) => !removedExistingIds.includes(image.id))
    const newImages = pendingFiles.map((file, index) => ({
      type: "new",
      file,
      id: `new-${index}`,
      url: URL.createObjectURL(file)
    }))

    return [...visibleExisting, ...newImages].slice(0, maxFiles)
  }

  function clearGallery() {
    gallery.innerHTML = ""
    gallery.className = "mt-4 hidden overflow-hidden rounded-[22px] border border-white/10 bg-black/20"

    if (counter) {
      counter.className = "mt-2 hidden text-sm text-[#8a9098]"
      counter.textContent = `Можно добавить до ${maxFiles} фотографий`
    }
  }

  function renderGallery() {
    const items = currentItems()
    gallery.innerHTML = ""

    if (items.length === 0) {
      clearGallery()
      return
    }

    gallery.className = "mt-4 overflow-hidden rounded-[22px] border border-white/10 bg-black/20"

    if (counter) {
      counter.className = "mt-2 text-sm text-[#8a9098]"
      counter.textContent = `Фотографий: ${items.length}/${maxFiles}`
    }

    const grid = document.createElement("div")
    grid.className = xGridClass(items.length)
    gallery.appendChild(grid)

    items.forEach((item, index) => {
      const wrapper = document.createElement("div")
      wrapper.className = xWrapperClass(items.length, index)

      const img = document.createElement("img")
      img.className = xImageClass(items.length, index)
      img.alt = "Фото публикации"
      img.src = item.url

      const removeButton = document.createElement("button")
      removeButton.type = "button"
      removeButton.className = "absolute right-2 top-2 flex h-8 w-8 items-center justify-center rounded-full bg-black/75 text-xl leading-none text-white transition hover:bg-black"
      removeButton.setAttribute("aria-label", "Удалить фото")
      removeButton.textContent = "×"

      removeButton.addEventListener("click", () => {
        if (item.type === "existing") {
          removedExistingIds.push(item.id)
          syncRemovedInputs()
        } else {
          const fileIndex = pendingFiles.indexOf(item.file)
          if (fileIndex >= 0) pendingFiles.splice(fileIndex, 1)
          syncFileInput()
        }

        renderGallery()
      })

      wrapper.appendChild(img)
      wrapper.appendChild(removeButton)
      grid.appendChild(wrapper)
    })
  }

  input.addEventListener("change", () => {
    const pickedFiles = Array.from(input.files || []).filter((file) => file.type.startsWith("image/"))
    const freeSlots = maxFiles - currentItems().length

    if (freeSlots > 0) {
      pendingFiles = [...pendingFiles, ...pickedFiles.slice(0, freeSlots)]
    }

    syncFileInput()
    renderGallery()
  })

  syncRemovedInputs()
  renderGallery()
}

document.addEventListener("DOMContentLoaded", setupPostImagePreview)
document.addEventListener("turbo:load", setupPostImagePreview)
