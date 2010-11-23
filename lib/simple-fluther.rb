require 'simple-fluther/config'
require 'simple-fluther/controller_methods'
require 'simple-fluther/feeds'

module SimpleFluther
  ClientVersion = '1.0.2'.freeze
  FederatedHost = 'http://r1.federated.fluther.com'.freeze
  UserAgent = "Fluther Federated Client #{SimpleFluther::ClientVersion} (Ruby)".freeze
end