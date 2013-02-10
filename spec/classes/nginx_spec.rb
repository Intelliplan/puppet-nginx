#!/usr/bin/env rspec

require 'spec_helper'

describe 'nginx', :type => :class do
  it { should contain_class 'nginx' }
end
