require 'bundler/setup'
require 'sinatra/base'
require 'rack/rewrite'

# The project root directory
$root = ::File.dirname(__FILE__)

# Rewrite known incoming Wordpress links
use Rack::Rewrite do
  r301 %r{^/blog/aes-commoncrypto-564}, '/blog/aes-commoncrypto/'
  r301 %r{^/blog/offline-uiwebview-nsurlprotocol-588}, '/blog/offline-uiwebview-nsurlprotocol/'
  r301 %r{^/blog/build-system-1-build-panel-360}, '/blog/build-system-1-build-panel/'
  r301 %r{^/blog/mode-rncryptor-767}, '/blog/mode-rncryptor/'
  r301 %r{^/blog/three-magic-words-6}, '/blog/three-magic-words/'
  r301 %r{^/blog/wrapping-c-take-2-1-486}, '/blog/wrapping-c-take-2-1/'
  r301 %r{^/blog/scripting-bridge-265}, '/blog/scripting-bridge/'
  r301 %r{^/blog/wrapping-cppfinal-edition-759}, '/blog/wrapping-cppfinal-edition/'
  r301 %r{^/blog/implementing-nscopying-439}, '/blog/implementing-nscopying/'
  r301 %r{^/blog/wrapping-text-around-shape-with-coretext-540}, '/blog/wrapping-text-around-shape-with-coretext/'
  r301 %r{^/blog/obfuscating-cocoa-389}, '/blog/obfuscating-cocoa/'
  r301 %r{^/blog/hijacking-methodexchangeimplementations-502}, '/blog/hijacking-methodexchangeimplementations/'
  r301 %r{^/blog/iphone-course-syllabus-158}, '/blog/iphone-course-syllabus/'
  r301 %r{^/blog/clipping-cgrect-cgpath-531}, '/blog/clipping-cgrect-cgpath/'
  r301 %r{^/blog/wrapping-c-objc-20}, '/blog/wrapping-c-objc/'
  r301 %r{^/blog/laying-out-text-with-coretext-547}, '/blog/laying-out-text-with-coretext/'
  r301 %r{^/blog/simple-gcd-timer-rntimer-762}, '/blog/simple-gcd-timer-rntimer/'
  r301 %r{^/blog/project-templates-364}, '/blog/project-templates/'
  r301 %r{^/blog/fast-bezier-intro-701}, '/blog/fast-bezier-intro/'
  r301 %r{^/blog/learning-cocoa-2-467}, '/blog/learning-cocoa-2/'
  r301 %r{^/blog/faster-bezier-722}, '/blog/faster-bezier/'
  r301 %r{^/blog/phone-screen-777}, '/blog/phone-screen/'
  r301 %r{^/blog/wrapping-c-take-2-2-493}, '/blog/wrapping-c-take-2-2/'
  r301 %r{^/blog/equations-matrices-accelerate-607}, '/blog/equations-matrices-accelerate/'
  r301 %r{^/blog/thoughts-nsnotifications-42}, '/blog/thoughts-nsnotifications/'
  r301 %r{^/blog/animating-arbitrary-keypaths-812}, '/blog/animating-arbitrary-keypaths/'
  r301 %r{^/blog/rncryptor-hmac-vulnerability-827}, '/blog/rncryptor-hmac-vulnerability/'
  r301 %r{^/blog/learning-cocoa-95}, '/blog/learning-cocoa/'
  r301 %r{^/blog/understanding-systemprofiler-393}, '/blog/understanding-systemprofiler/'
  r301 %r{^/blog/xcode-visual-studio-114}, '/blog/xcode-visual-studio/'
  r301 %r{^/blog/view-controllers-notifications-160}, '/blog/view-controllers-notifications/'
  r301 %r{^/blog/review-iphone-developers-cookbook-260}, '/blog/review-iphone-developers-cookbook/'
  r301 %r{^/blog/learning-iphone-scratch-134}, '/blog/learning-iphone-scratch/'
  r301 %r{^/blog/rncryptor-async-772}, '/blog/rncryptor-async/'
  r301 %r{^/blog/ios5-ptl-kindle-585}, '/blog/ios5-ptl-kindle/'
  r301 %r{^/blog/pbkdf2-sha1-799}, '/blog/pbkdf2-sha1/'
  r301 %r{^/blog/about-2}, '/blog/about/'
  r301 %r{^/blog/memory-managing-iboutlets-17}, '/blog/memory-managing-iboutlets/'
  r301 %r{^/blog/rncryptor-vulnerability-fix-832}, '/blog/rncryptor-vulnerability-fix/'
  r301 %r{^/blog/github-pricing-754}, '/blog/github-pricing/'
  r301 %r{^/blog/core-data-rdbms-11}, '/blog/core-data-rdbms/'
  r301 %r{^/blog/updated-rncryptor-784}, '/blog/updated-rncryptor/'
  r301 %r{^/blog/rncryptor-titanium-794}, '/blog/rncryptor-titanium/'
  r301 %r{^/blog/triangle-cocoaheads-march-745}, '/blog/triangle-cocoaheads-march/'
end

# To deal with:
# /blog/wp-content/uploads/2012/03/Building-a-Core-Foundation.pdf
# /blog/cocoaconf

class SinatraStaticServer < Sinatra::Base

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_file(File.join(File.dirname(__FILE__), 'public', '404.html'), {:status => 404})
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
