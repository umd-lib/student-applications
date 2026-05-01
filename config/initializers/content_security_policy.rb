# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# UMD Customization
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.connect_src :self
    policy.font_src    :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.script_src_attr :unsafe_inline # Required due to JQuery
    policy.style_src :self, :unsafe_inline
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end
  #
  #   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  #   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  #   config.content_security_policy_nonce_directives = %w(script-src style-src)
  #
  #   # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  #   # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  #   # config.content_security_policy_nonce_auto = true
  #
  #   # Report violations without enforcing the policy.
  #   # config.content_security_policy_report_only = true
end
# End UMD Customization
