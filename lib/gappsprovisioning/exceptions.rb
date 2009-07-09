#!/usr/bin/ruby
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0 
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
module GAppsProvisioning #:nodoc:
  class GDataError < RuntimeError
    ERROR_CODES = {
      '1000' => { :klass => 'UnknownError', :message => 'The request failed for an unknown reason.' },
      '1001' => { :klass => 'ServerBusy', :message => 'The server is busy and it could not complete the request.' },
      '1100' => { :klass => 'UserDeletedRecently', :message => 'The request instructs Google to create a new user but uses the username of an account that was deleted in the previous five days.' },
      '1101' => { :klass => 'UserSuspended', :message => 'The user identified in the request is suspended.' },
      '1200' => { :klass => 'DomainUserLimitExceeded', :message => 'The specified domain has already reached its quota of user accounts.' },
      '1201' => { :klass => 'DomainAliasLimitExceeded', :message => 'The specified domain has already reached its quota of aliases. Aliases include nicknames and email lists.' },
      '1202' => { :klass => 'DomainSuspended', :message => 'Google has suspended the specified domain\'s access to Google Apps.' },
      '1203' => { :klass => 'DomainFeatureUnavailable', :message => 'This particular feature is not available for the specified domain.' },
      '1300' => { :klass => 'EntityExists', :message => 'The request instructs Google to create an entity that already exists.' },
      '1301' => { :klass => 'EntityDoesNotExist', :message => 'The request asks Google to retrieve an entity that does not exist.' },
      '1302' => { :klass => 'EntityNameIsReserved', :message => 'The request instructs Google to create an entity with a reserved name, such as "abuse" or "postmaster".' },
      '1303' => { :klass => 'EntityNameNotValid', :message => 'The request provides an invalid name for a requested resource.' },
      '1400' => { :klass => 'InvalidGivenName', :message => 'The value in the API request for the user\'s first name, or given name, contains unaccepted characters.' },
      '1401' => { :klass => 'InvalidFamilyName', :message => 'The value in the API request for the user\'s surname, or family name, contains unaccepted characters.' },
      '1402' => { :klass => 'InvalidPassword', :message => 'The value in the API request for the user\'s password contains an invalid number of characters or unaccepted characters.' },
      '1403' => { :klass => 'InvalidUsername', :message => 'The value in the API request for the user\'s username contains unaccepted characters.' },
      '1404' => { :klass => 'InvalidHashFunctionName', :message => 'The specified query parameter value is not valid.' },
      '1405' => { :klass => 'InvalidHashDigestLength', :message => 'The specified password does not comply with the specified hash function.' },
      '1406' => { :klass => 'InvalidEmailAddress', :message => 'The specified email address is not valid.' },
      '1407' => { :klass => 'InvalidQueryParameterValue', :message => 'The specified query parameter value is not valid.' },
      '1408' => { :klass => 'InvalidSsoSigningKey', :message => 'The specified signing key is not valid.' },
      '1500' => { :klass => 'TooManyRecipientsOnEmailList', :message => 'The request instructs Google to add users to an email list, but that list has already reached the maximum number of subscribers (1000).' },
      '1501' => { :klass => 'TooManyNicknamesForUser', :message => 'The request instructs Google to add a nickname to an email address, but that email address has already reached the maximum number of nicknames.' },
      '1601' => { :klass => 'DuplicateDestinations', :message => 'The destination specified has already been used.' },
      '1602' => { :klass => 'TooManyDestinations', :message => 'The maximum number of destinations has been reached.' },
      '1603' => { :klass => 'InvalidRouteAddress', :message => 'The routing address specified is invalid.' },
      '1700' => { :klass => 'GroupCannotContainCycle', :message => 'A group cannot contain a cycle.' },
      '1800' => { :klass => 'InvalidDomainEdition', :message => 'The domain edition is not valid.' },
      '1801' => { :klass => 'InvalidValue', :message => 'A value specified is not valid.' },
      '9999' => { :klass => 'UnknownErrorCode', :message => 'The error code is not listed in the API documentation.' },
    }
    
    attr_accessor :code, :input, :reason
    def gdata_error_message
      ERROR_CODES.fetch(@code, ERROR_CODES['9999'])[:message]
    end
    
    def gdata_error_class
      ERROR_CODES.fetch(@code, ERROR_CODES['9999'])[:klass]
    end
  end
end
