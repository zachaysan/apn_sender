#!/usr/bin/ruby
# Based on https://gist.github.com/nickyp/886884/raw/aeba047a93a42debe2ab4f4680cafa94facfb680/self_signed_cert.rb

require 'rubygems'
require 'openssl'

key = OpenSSL::PKey::RSA.new(1024)
public_key = key.public_key

subject = "/C=BE/O=Test/OU=Test/CN=Test"

cert = OpenSSL::X509::Certificate.new
cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
cert.not_before = Time.now
cert.not_after = Time.now + 365 * 24 * 60 * 60
cert.public_key = public_key
cert.serial = 0x0
cert.version = 2

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.extensions = [
  ef.create_extension("basicConstraints","CA:TRUE", true),
  ef.create_extension("subjectKeyIdentifier", "hash")
]
cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                       "keyid:always,issuer:always")

cert.sign key, OpenSSL::Digest::SHA1.new



File.open("priv.pem", "w+") do |f|
  f.write(key.to_pem)
  f.write(public_key.to_pem)
end

File.open("apn_production.pem", "w+") do |f|
  f.write(public_key.to_pem)
  f.write(cert.to_pem)
end
