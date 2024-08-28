;; extends

; AlpineJS attributes
(jsx_attribute
  (property_identifier) @_attr
    (#lua-match? @_attr "^x%-%l")
  (string
    (string_fragment) @injection.content)
  (#set! injection.language "javascriptreact"))

