# Image processing configuration for performance optimization
# This ensures images are properly optimized when using Active Storage

Rails.application.config.to_prepare do
  # Use ImageMagick or libvips for image processing
  # libvips is faster and uses less memory
  Rails.application.config.active_storage.variant_processor = :vips
  
  # Configure default image variants for better performance
  # These will be used throughout the application
  Rails.application.config.active_storage.previewers = [
    ActiveStorage::Previewer::PopplerPDFPreviewer,
    ActiveStorage::Previewer::MuPDFPreviewer,
    ActiveStorage::Previewer::VideoPreviewer
  ]
  
  # Set reasonable limits for image processing
  Rails.application.config.active_storage.content_types_to_serve_as_binary = [
    "text/html",
    "text/javascript",
    "image/svg+xml",
    "application/postscript",
    "application/x-shockwave-flash",
    "text/xml",
    "application/xml",
    "application/xhtml+xml",
    "application/mathml+xml",
    "text/cache-manifest"
  ]
end
