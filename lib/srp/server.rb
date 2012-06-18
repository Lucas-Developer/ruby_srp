require File.expand_path(File.dirname(__FILE__) + '/util')

module SRP
  class Server

    include Util

    def initialize(salt, verifier)
      @salt = salt
      @verifier = verifier
    end

    def initialize_auth(aa)
      @b = bigrand(32).hex
      # B = g^b + k v (mod N)
      @bb = (modpow(GENERATOR, @b, PRIME_N) + multiplier * @verifier) % PRIME_N
      u = calculate_u(aa, @bb, PRIME_N)
      return @bb, u
    end

    def authenticate(aa, client_s)
      u = calculate_u(aa, @bb, PRIME_N)
      base = (modpow(@verifier, u, PRIME_N) * aa) % PRIME_N
      server_s = modpow(base, @b, PRIME_N)
      return client_s == server_s
    end


    protected

    def calculate_u(aa, bb, n)
      nlen = 2 * ((('%x' % [n]).length * 4 + 7) >> 3)
      aahex = '%x' % [aa]
      bbhex = '%x' % [bb]
      hashin = '0' * (nlen - aahex.length) + aahex \
        + '0' * (nlen - bbhex.length) + bbhex
      sha1_hex(hashin).hex
    end
  end
end

