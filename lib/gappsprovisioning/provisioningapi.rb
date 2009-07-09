#!/usr/bin/ruby
  # == Google Apps Provisioning API client library
  #
  # This library allows you to manage your domain (accounts, email lists, aliases) within your Ruby code.
  # It's based on the GDATA provisioning API v2.0.
  # Reference : http://code.google.com/apis/apps/gdata_provisioning_api_v2.0_reference.html.
  #
  # All the public methods with _ruby_style_ names are aliased with _javaStyle_ names. Ex : create_user and createUser.
  #
  # Notice : because it uses REXML, your script using this library MUST be encoded in unicode (UTF-8).
  #
  # == Examples
  #
  # #!/usr/bin/ruby
  # require 'gappsprovisioning/provisioningapi'
  # include GAppsProvisioning
  # adminuser = "root@mydomain.com"
  # password  = "PaSsWo4d!"
  # myapps = ProvisioningApi.new(adminuser,password)  
  # (see examples in  ProvisioningApi.new documentation for handling proxies)
  #
  # new_user = myapps.create_user("jsmith", "john", "smith", "secret", nil, "2048")
  # puts new_user.family_name
  # puts new_user.given_name
  # 
  # Want to update a user ?
  #
  # user = myapps.retrieve_user('jsmith')
  # user_updated = myapps.update_user(user.username, user.given_name, user.family_name, nil, nil, "true")
  #
  # Want to add an alias or nickname ?
  #
  #   new_nickname = myapps.create_nickname("jsmith", "john.smith")
  #
  # Want to handle errors ?
  #
  # begin
  #   user = myapps.retrieve_user('noone')
  #   puts "givenName : "+user.given_name, "familyName : "+user.family_name, "username : "+user.username"
  #   puts "admin ? : "+user.admin
  # rescue GDataError => e
  #   puts "errorcode = " +e.code, "input : "+e.input, "reason : "+e.reason
  # end
  #
  # Email lists ?
  #
  #   new_list = myapps.create_email_list("sale-dep")
  #   new_address = myapps.add_address_to_email_list("sale-dep", "bibi@ruby-forge.org")
  #
  # All methods described in the GAppsProvisioning::ProvisioningApi class documentation.
  #
  # Author :: Jérôme Bousquié
  # Ruby version :: from 1.8.6
  # Licence :: Apache Licence, version 2
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
#

# require 'cgi'
# require 'rexml/document'

# require 'gappsprovisioning/connection'
# require 'gappsprovisioning/exceptions'

include REXML

module GAppsProvisioning #:nodoc:

  # =Administrative object for accessing your domain
  # Examples
  #
  # adminuser = "root@mydomain.com"
  # password  = "PaSsWo4d!"
  # myapps = ProvisioningApi.new(adminuser,password)  
  # (see examples in  ProvisioningApi.new documentation for handling proxies)
  #
  # new_user = myapps.create_user("jsmith", "john", "smith", "secret", nil, "2048")
  # puts new_user.family_name
  # puts new_user.given_name
  # 
  # Want to update a user ?
  #
  # user = myapps.retrieve_user('jsmith')
  # user_updated = myapps.update_user(user.username, user.given_name, user.family_name, nil, nil, "true")
  #
  # Want to add an alias or nickname ?
  #
  #   new_nickname = myapps.create_nickname("jsmith", "john.smith")
  #
  # Want to handle errors ?
  #
  # begin
  #   user = myapps.retrieve_user('noone')
  #   puts "givenName : "+user.given_name, "familyName : "+user.family_name, "username : "+user.username"
  #   puts "admin ? : "+user.admin
  # rescue GDataError => e
  #   puts "errorcode = " +e.code, "input : "+e.input, "reason : "+e.reason
  # end
  #
  # Email lists ?
  #
  #   new_list = myapps.create_email_list("sale-dep")
  #   new_address = myapps.add_address_to_email_list("sale-dep", "bibi@ruby-forge.org")
  #


  class ProvisioningApi
    @@google_host = 'apps-apis.google.com'
    @@google_port = 443
    # authentication token, valid up to 24 hours after the last connection
    attr_reader :token


  # Creates a new ProvisioningApi object
  #
  #   mail : Google Apps domain administrator e-mail (string)
  #   passwd : Google Apps domain administrator password (string)
  #   proxy : (optional) host name, or IP, of the proxy (string)
  #   proxy_port : (optional) proxy port number (numeric)
  #   proxy_user : (optional) login for authenticated proxy only (string)
  #   proxy_passwd : (optional) password for authenticated proxy only (string)
  #
  #  The domain name is extracted from the mail param value.
  #
  # Examples :
  #   standard : no proxy
  #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
  #   proxy :
  #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd','domain.proxy.com',8080)
  #   authenticated proxy :
  #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd','domain.proxy.com',8080,'foo','bAr')
    def initialize(mail, passwd, proxy=nil, proxy_port=nil, proxy_user=nil, proxy_passwd=nil)
      domain = mail.split('@')[1]
      @action = setup_actions(domain)
      conn = Connection.new(@@google_host, @@google_port, proxy, proxy_port, proxy_user, proxy_passwd)
      @connection = conn
      @token = login(mail, passwd)
      @headers = {'Content-Type'=>'application/atom+xml', 'Authorization'=> 'GoogleLogin auth='+token}
      return @connection
    end
  
    
  
    # Returns a UserEntry instance from a username
    #   ex :  
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     user = myapps.retrieve_user('jsmith')
    #     puts "givenName : "+user.given_name
    #     puts "familyName : "+user.family_name
    def retrieve_user(username)
      xml_response = request(:user_retrieve, username, @headers) 
      user_entry = UserEntry.new(xml_response.elements["entry"])
    end
 
    # Returns a UserEntry array populated with all the users in the domain. May take a while depending on the number of users in your domain.
    #   ex :  
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     list= myapps.retrieve_all_users
    #     list.each{ |user| puts user.username} 
    #     puts 'nb users : ',list.size
    def retrieve_all_users
      response = request(:user_retrieve_all,nil,@headers)
      user_feed = Feed.new(response.elements["feed"],  UserEntry)
      user_feed = add_next_feeds(user_feed, response, UserEntry)
    end

    # Returns a UserEntry array populated with 100 users, starting from a username
    #   ex :  
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     list= myapps.retrieve_page_of_users("jsmtih")
    #     list.each{ |user| puts user.username}
    def retrieve_page_of_users(start_username)
      param='?startUsername='+start_username
      response = request(:user_retrieve_all,param,@headers)
      user_feed = Feed.new(response.elements["feed"],  UserEntry)
    end
 
    # Creates an account in your domain, returns a UserEntry instance
    #   params :
    #     username, given_name, family_name and password are required
    #     passwd_hash_function (optional) : nil (default) or "SHA-1"
    #     quota (optional) : nil (default) or integer for limit in MB
    #   ex :  
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     user = myapps.create('jsmith', 'John', 'Smith', 'p455wD')
    #
    # By default, a new user must change his password at first login. Please use update_user if you want to change this just after the creation.
    def create_user(username, given_name, family_name, password, passwd_hash_function=nil, quota=nil, suspended=nil)
      msg = RequestMessage.new
      msg.about_login(username,password,passwd_hash_function,"false",suspended,"true")
      msg.about_name(family_name, given_name)
      msg.about_quota(quota.to_s) if quota
      response  = request(:user_create,nil,@headers, msg.to_s)
      user_entry = UserEntry.new(response.elements["entry"])
    end

    # Updates an account in your domain, returns a UserEntry instance
    #   params :
    #     username is required and can't be updated.
    #     given_name and family_name are required, may be updated.
    #     if set to nil, every other parameter won't update the attribute.
    #       passwd_hash_function :  string "SHA-1" or nil (default)
    #       admin :  string "true" or string "false" or nil (no boolean : true or false). 
    #       suspended :  string "true" or string "false" or nil (no boolean : true or false)
    #       change_passwd :  string "true" or string "false" or nil (no boolean : true or false)
    #       quota : limit en MB, ex :  string "2048"
    #   ex :
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     user = myapps.update('jsmith', 'John', 'Smith', nil, nil, "true", nil, "true", nil)
    #     puts user.admin   => "true"
    def update_user(username, given_name, family_name, password=nil, passwd_hash_function=nil, admin=nil, suspended=nil, changepasswd=nil, quota=nil)
      msg = RequestMessage.new
      msg.about_login(username,password,passwd_hash_function,admin,suspended,changepasswd)
      msg.about_name(family_name, given_name)
      msg.about_quota(quota) if quota
      msg.add_path('https://'+@@google_host+@action[:user_update][:path]+username)
      response  = request(:user_update,username,@headers, msg.to_s)
      user_entry = UserEntry.new(response.elements["entry"])
    end
  
    # Suspends an account in your domain, returns a UserEntry instance
    #   ex :
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     user = myapps.suspend('jsmith')
    #     puts user.suspended   => "true"
    def suspend_user(username)
      msg = RequestMessage.new
      msg.about_login(username,nil,nil,nil,"true")
      msg.add_path('https://'+@@google_host+@action[:user_update][:path]+username)
      response  = request(:user_update,username,@headers, msg.to_s)
      user_entry = UserEntry.new(response.elements["entry"])
    end

    # Restores a suspended account in your domain, returns a UserEntry instance
    #   ex :
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     user = myapps.restore('jsmith')
    #     puts user.suspended   => "false"
    def restore_user(username)
      msg = RequestMessage.new
      msg.about_login(username,nil,nil,nil,"false")
      msg.add_path('https://'+@@google_host+@action[:user_update][:path]+username)
      response  = request(:user_update,username,@headers, msg.to_s)
      user_entry = UserEntry.new(response.elements["entry"])
    end

    # Deletes an account in your domain
    #   ex :
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     myapps.delete('jsmith')
    def delete_user(username)
      response  = request(:user_delete,username,@headers)
    end

    
    # Returns a NicknameEntry instance from a nickname
    #   ex :  
    #     myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     nickname = myapps.retrieve_nickname('jsmith')
    #     puts "login : "+nickname.login
    def retrieve_nickname(nickname)
      xml_response = request(:nickname_retrieve, nickname, @headers)
      nickname_entry = NicknameEntry.new(xml_response.elements["entry"])
    end
  
    # Returns a NicknameEntry array from a username
    # ex : lists jsmith's nicknames
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     mynicks = myapps.retrieve('jsmith')
    #   mynicks.each {|nick| puts nick.nickname }
    def retrieve_nicknames(username)
      xml_response = request(:nickname_retrieve_all_for_user, username, @headers)
      nicknames_feed = Feed.new(xml_response.elements["feed"],  NicknameEntry)
      nicknames_feed = add_next_feeds(nicknames_feed, xml_response, NicknameEntry)
    end
  
    # Returns a NicknameEntry array for the whole domain. May take a while depending on the number of users in your domain.
    # myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   allnicks = myapps.retrieve_all_nicknames
    #   allnicks.each {|nick| puts nick.nickname }
    def retrieve_all_nicknames
      xml_response = request(:nickname_retrieve_all_in_domain, nil, @headers)
      nicknames_feed = Feed.new(xml_response.elements["feed"],  NicknameEntry)
      nicknames_feed = add_next_feeds(nicknames_feed, xml_response, NicknameEntry)
    end

    # Creates a nickname for the username in your domain and returns a NicknameEntry instance
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     mynewnick = myapps.create_nickname('jsmith', 'john.smith')
    def create_nickname(username,nickname)
      msg = RequestMessage.new
      msg.about_login(username)
      msg.about_nickname(nickname)
      response  = request(:nickname_create,nil,@headers, msg.to_s)
      nickname_entry = NicknameEntry.new(response.elements["entry"])
    end
    
    # Deletes the nickname  in your domain 
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #     myapps.delete_nickname('john.smith')
    def delete_nickname(nickname)
      response  = request(:nickname_delete,nickname,@headers)
    end
  
    # Returns a NicknameEntry array populated with 100 nicknames, starting from a nickname
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   list= myapps.retrieve_page_of_nicknames("joe")
    #     list.each{ |nick| puts nick.login}
    def retrieve_page_of_nicknames(start_nickname)
      param='?startNickname='+start_nickname
      xml_response = request(:nickname_retrieve_all_in_domain, param, @headers)
      nicknames_feed = Feed.new(xml_response.elements["feed"],  NicknameEntry)
    end
  
    # Groups API
    # This method takes four arguments:
    #   The group_id (required) argument identifies the ID of the new group.
    #   The group_name (required) argument identifies the name of the group being added.
    #   The description argument provides a general description of the group.
    #   The email_permission argument sets the permissions level of the group.
    #     Owner - Owners of the group
    #     Member - Members of the group
    #     Domain - Any user who belongs to the same domain as the group
    #     Anyone - Any user
    # Note: A newly created group does not have any subscribers. You must call 
    # the add_member_to_group method to add members to a group.
    def create_group(group_id, group_name, description, email_permission)
      msg = RequestMessage.new(false)
      msg.about_group(group_id, group_name, description, email_permission)
      xml_response = request(:group_create, nil, @headers, msg.to_s)
      group_entry = GroupEntry.new(xml_response.elements["entry"])
    end
    
    def retrieve_group(group_id)
      xml_response = request(:group_retrieve, group_id, @headers)
      group_entry = GroupEntry.new(xml_response.elements["entry"])
    end

    def update_group(group_id, group_name, description, email_permission)
      msg = RequestMessage.new(false)
      msg.about_group(group_id, group_name, description, email_permission)
      xml_response = request(:group_update, group_id, @headers)
      group_entry = GroupEntry.new(xml_response.elements["entry"])
    end
    
    # Retrieve all Groups for a Member
    # This method takes two arguments:
    #   The member_id (required) argument identifies the ID of a hosted user 
    #     for which you want to retrieve group subscriptions.
    #   If true, direct_only identifies only members with direct association.
    def retrieve_groups(member_id, direct_only=true)
      for_member = '?member='+member_id
      for_member << '&directOnly=true' if direct_only
      xml_response = request(:group_retrieve, for_member, @headers)
      group_feed = Feed.new(xml_response.elements["feed"], GroupEntry) 
    end
    
    def retrieve_all_groups
      # start_at = '?start='+start
      xml_response = request(:group_retrieve, nil, @headers)
      group_feed = Feed.new(xml_response.elements["feed"], GroupEntry) 
    end

    def delete_group(group_id)
      response = request(:group_delete, group_id, @headers)
    end
    
    # Add a Member to a Group
    # This method takes two arguments:
    #   The group_id argument identifies the group to which the address 
    #     is being added.
    #   The member_id argument identifies the name of the member that is 
    #     being added to a group.
    def add_member_to_group(member_id, group_id)
      msg = RequestMessage.new(false)
      msg.about_member(member_id)
      add_member = group_id+'/member'
      xml_response = request(:group_add_member, add_member, @headers, msg.to_s)
      member_entry = MemberEntry.new(xml_response.elements["entry"])
    end

    def retrieve_all_members(group_id)
      all_members = group_id+'/member'
      # all_members << '&start='+start
      xml_response = request(:group_retrieve, all_members, @headers)
      member_feed = Feed.new(xml_response.elements["feed"], MemberEntry) 
    end

    def is_member?(member_id, group_id)
      membership = group_id+'/member/'+member_id
      request_valid_object?(:group_retrieve, membership, @headers)
    end

    def remove_member_from_group(member_id, group_id)
      membership = group_id+'/member/'+member_id
      str_response = request(:group_delete, membership, @headers)
    end
    
    # Methods for Group Owners
    def add_owner_to_group(owner_email, group_id)
      msg = RequestMessage.new(false)
      msg.about_owner(owner_email)
      add_owner = group_id+'/owner'
      xml_response = request(:group_add_member, add_owner, @headers, msg.to_s)
      owner_entry = OwnerEntry.new(xml_response.elements["entry"])
    end
    
    def retrieve_all_owners(group_id)
      all_owners = group_id+'/member'
      # all_owners << '&start='+start
      xml_response = request(:group_retrieve, all_owners, @headers)
      owner_feed = Feed.new(xml_response.elements["feed"], OwnerEntry) 
    end
    
    def is_owner?(owner_email, group_id)
      ownership = group_id+'/owner/'+owner_email
      request_valid_object?(:group_retrieve, ownership, @headers)
    end

    def remove_owner_from_group(owner_email, group_id)
      ownership = group_id+'/owner/'+owner_email
      xml_response = request(:group_delete, ownership, @headers)
    end

    # Obsolete: EmailList API
    # Returns an EmailListEntry array from an email adress
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   mylists = myapps.retrieve_email_lists('jsmith')   <= you could search from 'jsmith@mydomain.com' too 
    #     mylists.each {|list| puts list.email_list }
    def retrieve_email_lists(email_adress)
      xml_response = request(:email_list_retrieve_for_an_email, email_adress, @headers)
      email_list_feed = Feed.new(xml_response.elements["feed"],  EmailListEntry) 
      email_list_feed = add_next_feeds(email_list_feed, xml_response, EmailListEntry)
    end   
  
    # Returns an EmailListEntry array for the whole domain
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   all_lists = myapps.retrieve_all_email_lists
    #     all_lists.each {|list| puts list.email_list }
    def retrieve_all_email_lists
      xml_response = request(:email_list_retrieve_in_domain, nil, @headers)
      email_list_feed = Feed.new(xml_response.elements["feed"],  EmailListEntry) 
      email_list_feed = add_next_feeds(email_list_feed, xml_response, EmailListEntry)
    end
  
    # Returns an EmailListEntry array populated with 100 email lists, starting from an email list name.
    # Starting email list name must be written "mylist", not "mylist@mydomain.com". Omit "@mydomain.com".
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   list= myapps.retrieve_page_of_email_lists("mylist") 
    #     list.each{ |entry| puts entry.email_list}
    def retrieve_page_of_email_lists(start_listname)
      param='?startEmailListName='+start_listname
      xml_response = request(:email_list_retrieve_in_domain, param, @headers)
      email_list_feed = Feed.new(xml_response.elements["feed"],  EmailListEntry)
    end
    
    # Creates an email list in your domain and returns an EmailListEntry
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   list= myapps.create_email_lists("mylist") 
    def create_email_list(name)
      msg = RequestMessage.new
      msg.about_email_list(name)
      response  = request(:email_list_create,nil,@headers, msg.to_s)
      email_list_entry = EmailListEntry.new(response.elements["entry"])
    end

    # Deletes an email list in your domain. Omit "@mydomain.com" in the email list name.
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   myapps.delete_email_lists("mylist")
    def delete_email_list(name)
      response  = request(:email_list_delete,name,@headers)
    end
  
    # Returns an EmailListRecipientEntry array for an email list. 
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   recipients = myapps.retrieve_all_recipients('mylist')  <= do not write "mylist@mydomain.com", write "mylist" only.
    #     recipients.each {|recipient| puts recipient.email }
    def retrieve_all_recipients(email_list)
      param = email_list+'/recipient/'
      xml_response = request(:subscription_retrieve, param, @headers)
      email_list_recipient_feed = Feed.new(xml_response.elements["feed"],  EmailListRecipientEntry) 
      email_list_recipient_feed = add_next_feeds(email_list_recipient_feed, xml_response, EmailListRecipientEntry)
    end
  
    # Returns an EmailListRecipientEntry Array populated with 100 recipients from an email list, starting from a recipient name.  Omit "@mydomain.com" in the email list name.
    #   ex :  
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   list= myapps.retrieve_page_of_recipients('mylist', 'jsmith') 
    #     list.each{ |recipient| puts recipient.email}
    def retrieve_page_of_recipients(email_list, start_recipient)
      param = email_list+'/recipient/?startRecipient='+start_recipient
      xml_response = request(:subscription_retrieve, param, @headers)
      recipients_feed = Feed.new(xml_response.elements["feed"], EmailListRecipientEntry)
    end
  
    # Adds an email address to an email list in your domain and returns an EmailListRecipientEntry instance.
    # You can add addresses from other domains to your email list.  Omit "@mydomain.com" in the email list name.
    # ex :
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   new_address = myapps.add_address_to_email_list('mylist', 'foo@otherdomain.com')
    def add_address_to_email_list(email_list,address)
      msg = RequestMessage.new
      msg.about_email_list(email_list)
      msg.about_who(address)
      response  = request(:subscription_add, email_list+'/recipient/',@headers, msg.to_s)
      email_list_recipient_entry = EmailListRecipientEntry.new(response.elements["entry"])
    end
  
    # Removes an address from an email list.
    #   ex :
    #   myapps = ProvisioningApi.new('root@mydomain.com','PaSsWoRd')
    #   myapps.remove_address_from_email_list('foo@otherdomain.com', 'mylist')
    def remove_address_from_email_list(address,email_list)
      response  = request(:subscription_remove, email_list+'/recipient/'+address,@headers)
    end
    
    # Aliases
    alias createUser create_user
    alias retrieveUser retrieve_user
    alias retrieveAllUsers retrieve_all_users
    alias retrievePageOfUsers retrieve_page_of_users
    alias updateUser update_user
    alias suspendUser suspend_user
    alias restoreUser restore_user
    alias deleteUser delete_user
    alias createNickname create_nickname
    alias retrieveNickname retrieve_nickname
    alias retrieveNicknames retrieve_nicknames
    alias retrieveAllNicknames retrieve_all_nicknames
    alias retrievePageOfNicknames retrieve_page_of_nicknames
    alias deleteNickname delete_nickname
    alias createGroup create_group
    alias retrieveGroup retrieve_group
    alias updateGroup update_group
    alias retrieveGroups  retrieve_groups
    alias retrieveAllGroups  retrieve_all_groups
    alias deleteGroup delete_group
    alias addMemberToGroup add_member_to_group
    alias retrieveAllMembers retrieve_all_members
    alias isMember is_member?
    alias removeMemberFromGroup remove_member_from_group
    alias addOwnerToGroup add_owner_to_group
    alias retrieveAllOwners retrieve_all_owners
    alias isOwner is_owner?
    alias removeOwnerFromGroup remove_owner_from_group
    # deprecated
    alias createEmailList create_email_list
    alias retrieveEmailLists retrieve_email_lists
    alias retrieveAllEmailLists retrieve_all_email_lists
    alias retrievePageOfEmailLists retrieve_page_of_email_lists
    alias deleteEmailList delete_email_list
    alias addRecipientToEmailList add_address_to_email_list
    alias retrieveAllRecipients retrieve_all_recipients
    alias retrievePageOfRecipients retrieve_page_of_recipients
    alias removeRecipientFromEmailList remove_address_from_email_list
  
    # private methods
    private #:nodoc:
    
    # Associates methods, http verbs and URL for REST access
    def setup_actions(domain)
      path_user       = '/a/feeds/'+domain+'/user/2.0'
      path_nickname   = '/a/feeds/'+domain+'/nickname/2.0'
      path_group      = '/a/feeds/group/2.0/'+domain
      # deprecated
      path_email_list = '/a/feeds/'+domain+'/emailList/2.0'
      action = Hash.new
      action[:domain_login]      = { :method => 'POST',   :path => '/accounts/ClientLogin' }
      action[:user_create]       = { :method => 'POST',   :path => path_user }
      action[:user_retrieve]     = { :method => 'GET',    :path => path_user+'/' }
      action[:user_retrieve_all] = { :method => 'GET',    :path => path_user } 
      action[:user_update]       = { :method => 'PUT',    :path => path_user +'/' }
      action[:user_delete]       = { :method => 'DELETE', :path => path_user +'/' }
      action[:nickname_create]   = { :method => 'POST',   :path => path_nickname }
      action[:nickname_retrieve] = { :method => 'GET',    :path => path_nickname+'/' }
      action[:nickname_retrieve_all_for_user]  = { :method => 'GET', :path =>path_nickname+'?username=' }
      action[:nickname_retrieve_all_in_domain] = { :method => 'GET', :path =>path_nickname }
      action[:nickname_delete]   = { :method => 'DELETE', :path =>path_nickname+'/' }
      action[:group_create]      = { :method => 'POST',   :path => path_group }
      action[:group_retrieve]    = { :method => 'GET',    :path => path_group+'/' }
      action[:group_update]      = { :method => 'PUT',    :path => path_group+'/' }
      action[:group_delete]      = { :method => 'DELETE', :path => path_group+'/' }
      action[:group_add_member]  = { :method => 'POST',   :path => path_group+'/' }
      # deprecated
      action[:email_list_retrieve_for_an_email] = { :method => 'GET', :path =>path_email_list+'?recipient=' }
      action[:email_list_retrieve_in_domain] = { :method => 'GET', :path =>path_email_list }
      action[:email_list_create] = { :method => 'POST', :path =>path_email_list }
      action[:email_list_delete] = { :method => 'DELETE', :path =>path_email_list+'/' }
      action[:subscription_retrieve] = {:method => 'GET', :path =>path_email_list+'/'}
      action[:subscription_add] = {:method => 'POST', :path =>path_email_list+'/'}
      action[:subscription_remove] = {:method => 'DELETE', :path =>path_email_list+'/'}
  
      # special action "next" for linked feed results. :path will be affected with URL received in a link tag.
      action[:next] = {:method => 'GET', :path =>nil }
      return action   
    end   
  
    # Sends credentials and returns an authentication token
    def login(mail, passwd)
      request_body = '&Email='+CGI.escape(mail)+'&Passwd='+CGI.escape(passwd)+'&accountType=HOSTED&service=apps'
      response = request_raw(:domain_login, nil, {'Content-Type'=>'application/x-www-form-urlencoded'}, request_body)
      return /^Auth=(.+)$/.match(response.body)[1]
    end
  

  # Completes the feed by following et requesting the URL links
    def add_next_feeds(current_feed, xml_content,element_class)
      xml_content.elements.each("feed/link") do |link|
        if link.attributes["rel"] == "next"
          @action[:next] = {:method => 'GET', :path=> link.attributes["href"]}
          next_response = request(:next,nil,@headers)
          current_feed.concat(Feed.new(next_response.elements["feed"], element_class))
          current_feed = add_next_feeds(current_feed, next_response, element_class)
        end
      end
      return current_feed
    end

    # Perfoms a REST request based on the action hash (cf setup_actions)
    # ex : request (:user_retrieve, 'jsmith') sends a http GET www.google.com/a/feeds/domain/user/2.0/jsmith  
    # returns REXML Document or HTTP message string if response does not have body
    def request(action, value=nil, header=nil, message=nil)
      response = request_raw(action, value, header, message)
      body = response.body
      if body && !body.empty?
        response_xml = Document.new(body)
        test_errors(response_xml)
        return response_xml
      end
      
      if response.kind_of?(Net::HTTPSuccess)
        response_str = "#{response.code} - #{response.message}"
        return response_str
      end
      response.error!
    end

    def request_valid_object?(action, value=nil, header=nil, message=nil)
      response = request_raw(action, value, header, message)
      body = response.body
      if body && !body.empty?
        response_xml = Document.new(body)
        error = response_xml.elements["AppsForYourDomainErrors/error"]
        return true if error.nil?
        return false if error.attributes["errorCode"] == '1301'
        raise_gdata_error(error)
      end
      return false
    end
    
    #param value : value to be concatenated to action path ex: GET host/path/value
    def request_raw(action, value=nil, header=nil, message=nil)
      method = @action[action][:method]
      value = '' if !value
      path = @action[action][:path]+value
      response = @connection.perform(method, path, message, header)
    end
    
    # parses xml response for an API error tag. If an error, constructs and raises a GDataError.
    def test_errors(xml)
      error = xml.elements["AppsForYourDomainErrors/error"]
      raise_gdata_error(error) if error
    end
    
    def raise_gdata_error(error_xml)
      gdata_error = GDataError.new
      gdata_error.code = error_xml.attributes["errorCode"]
      gdata_error.input = error_xml.attributes["invalidInput"]
      gdata_error.reason = error_xml.attributes["reason"]
      msg = "error code : "+gdata_error.code+", invalid input : "+gdata_error.input+", reason : "+gdata_error.reason
      raise gdata_error, msg
    end
  end

  # UserEntry object.
  #
  # Handles API responses relative to a user
  #
  # Attributes :
  # username : string
  # given_name : string
  # family_name : string
  # suspended : string "true" or string "false"
  # ip_whitelisted : string "true" or string "false"
  # admin : string "true" or string "false"
  # change_password_at_next_login : string "true" or string "false"
  # agreed_to_terms : string "true" or string "false"
  # quota_limit : string (value in MB)
  class UserEntry 
  attr_reader :given_name, :family_name, :username, :suspended, :ip_whitelisted, :admin, :change_password_at_next_login, :agreed_to_terms, :quota_limit
  
    # UserEntry constructor. Needs a REXML::Element <entry> as parameter
    def initialize(entry) #:nodoc:
      @family_name = entry.elements["apps:name"].attributes["familyName"]
      @given_name = entry.elements["apps:name"].attributes["givenName"]
      @username = entry.elements["apps:login"].attributes["userName"]
      @suspended = entry.elements["apps:login"].attributes["suspended"]
      @ip_whitelisted = entry.elements["apps:login"].attributes["ipWhitelisted"]
      @admin = entry.elements["apps:login"].attributes["admin"]
      @change_password_at_next_login = entry.elements["apps:login"].attributes["changePasswordAtNextLogin"]
      @agreed_to_terms = entry.elements["apps:login"].attributes["agreedToTerms"]
      @quota_limit = entry.elements["apps:quota"].attributes["limit"]
    end
  end


  # NicknameEntry object.
  #
  # Handles API responses relative to a nickname
  #
  # Attributes :
  # login : string
  # nickname : string
  class NicknameEntry
  attr_reader :login, :nickname
  
    # NicknameEntry constructor. Needs a REXML::Element <entry> as parameter
    def initialize(entry) #:nodoc:
    @login = entry.elements["apps:login"].attributes["userName"]
    @nickname = entry.elements["apps:nickname"].attributes["name"]
    end 
  end

  # GroupEntry object.
  #
  # Handles API responses relative to a nickname
  #
  # Attributes :
  # group_id : string
  class GroupEntry
  attr_reader :group_id, :group_name, :email_permission, :description

    def initialize(entry)
      entry.elements.each("apps:property") do |prop|
        prop_name = prop.attributes["name"]
        case prop_name
        when 'groupId'
          @group_id = prop.attributes["value"]
        when 'groupName'
          @group_name = prop.attributes["value"]
        when 'emailPermission'
          @email_permission = prop.attributes["value"]
        when 'description'
          @description = prop.attributes["value"]
        else
        end
      end
    end
  end
  
  class MemberEntry
  attr_reader :id, :member_id, :member_type, :direct_member
  
    def initialize(entry)
      @id = entry.elements["id"].get_text
      @direct_member = false
      entry.elements.each("apps:property") do |prop|
        prop_name = prop.attributes["name"]
        case prop_name
        when 'memberId'
          @member_id = prop.attributes["value"]
        when 'memberType'
          @member_type = prop.attributes["value"]
        when 'directMember'
          @direct_member = (prop.attributes["value"] == 'true')
        else
        end
      end
    end
  end

  class OwnerEntry
  attr_reader :id, :email
  
    def initialize(entry)
      @id = entry.elements["id"].get_text
      entry.elements.each("apps:property") do |prop|
        prop_name = prop.attributes["name"]
        case prop_name
        when 'email'
          @email = prop.attributes["value"]
        else
        end
      end
    end
  end

  # Obsolete
  # EmailListEntry object.
  #
  # Handles API responses relative to an email list.
  #
  # Attributes :
  # email_list : string . The email list name is written without "@" and everything following.
  class EmailListEntry 
  attr_reader :email_list
  
    # EmailListEntry constructor. Needs a REXML::Element <entry> as parameter
    def initialize(entry) #:nodoc:
    @email_list = entry.elements["apps:emailList"].attributes["name"]
    end 
  end


  # EmailListRecipientEntry object.
  #
  # Handles API responses relative to a recipient.
  #
  # Attributes :
  # email : string
  class EmailListRecipientEntry 
  attr_reader :email
  
    # EmailListEntry constructor. Needs a REXML::Element <entry> as parameter
    def initialize(entry) #:nodoc:
    @email = entry.elements["gd:who"].attributes["email"]
    end 
  end


  # UserFeed object : Array populated with Element_class objects (UserEntry, NicknameEntry, EmailListEntry or EmailListRecipientEntry)
  class Feed < Array #:nodoc:
  
    # UserFeed constructor. Populates an array with Element_class objects. Each object is an xml <entry> parsed from the REXML::Element <feed>.
    # Ex : user_feed = Feed.new(xml_feed, UserEntry)
    #       nickname_feed = Feed.new(xml_feed, NicknameEntry)
    def initialize(xml_feed, element_class)
      xml_feed.elements.each("entry"){ |entry| self << element_class.new(entry) }
    end
  end


  class RequestMessage < Document #:nodoc:
    # Request message constructor.
    # parameter type : "user", "nickname" or "emailList"  
    
    # creates the object and initiates the construction
    def initialize(with_category=true)
      super '<?xml version="1.0" encoding="UTF-8"?>' 
      self.add_element "atom:entry", {"xmlns:apps" => "http://schemas.google.com/apps/2006",
                "xmlns:gd" => "http://schemas.google.com/g/2005",
                "xmlns:atom" => "http://www.w3.org/2005/Atom"}
      self.elements["atom:entry"].add_element "atom:category", {"scheme" => "http://schemas.google.com/g/2005#kind"} if with_category
    end
 
    # adds <atom:id> element in the message body. Url is inserted as a text.
    def add_path(url)
      self.elements["atom:entry"].add_element "atom:id"
      self.elements["atom:entry/atom:id"].text = url
    end
    
    # The XML uses the "groupName" to specify the name of the group.
    def about_group(group_id, group_name, description=nil, email_permission='Member')
      self.elements["atom:entry"].add_element "apps:property", {"name" => "groupId", "value" => group_id } 
      self.elements["atom:entry"].add_element "apps:property", {"name" => "groupName", "value" => group_name } 
      self.elements["atom:entry"].add_element "apps:property", {"name" => "description", "value" => description } if not description.nil? 
      self.elements["atom:entry"].add_element "apps:property", {"name" => "emailPermission", "value" => email_permission } 
    end
    
    def about_member(member_id)
      self.elements["atom:entry"].add_element "apps:property", {"name" => "memberId", "value"=> member_id } 
    end

    def about_owner(owner_email)
      self.elements["atom:entry"].add_element "apps:property", {"name" => "email", "value" => owner_email } 
    end
 
    # deprecated
    # adds <apps:emailList> element in the message body.
    def about_email_list(email_list)
      self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#emailList")
      self.elements["atom:entry"].add_element "apps:emailList", {"name" => email_list } 
    end
    
 
    # adds <apps:login> element in the message body.
    # warning :  if valued admin, suspended, or change_passwd_at_next_login must be the STRINGS "true" or "false", not the boolean true or false
    # when needed to construct the message, should always been used before other "about_" methods so that the category tag can be overwritten
    # only values permitted for hash_function_function_name : "SHA-1" or nil
    def about_login(user_name, passwd=nil, hash_function_name=nil, admin=nil, suspended=nil, change_passwd_at_next_login=nil)
      self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#user")
      self.elements["atom:entry"].add_element "apps:login", {"userName" => user_name } 
      self.elements["atom:entry/apps:login"].add_attribute("password", passwd) if not passwd.nil?
      self.elements["atom:entry/apps:login"].add_attribute("hashFunctionName", hash_function_name) if not hash_function_name.nil?
      self.elements["atom:entry/apps:login"].add_attribute("admin", admin) if not admin.nil?
      self.elements["atom:entry/apps:login"].add_attribute("suspended", suspended) if not suspended.nil?
      self.elements["atom:entry/apps:login"].add_attribute("changePasswordAtNextLogin", change_passwd_at_next_login) if not change_passwd_at_next_login.nil?
      return self
    end
   
    # adds <apps:quota> in the message body.
    # limit in MB: integer
    def about_quota(limit)
      self.elements["atom:entry"].add_element "apps:quota", {"limit" => limit }  
      return self
    end    
 
    # adds <apps:name> in the message body.
    def about_name(family_name, given_name)
      self.elements["atom:entry"].add_element "apps:name", {"familyName" => family_name, "givenName" => given_name } 
      return self
    end

    # adds <apps:nickname> in the message body.
    def about_nickname(name)
      self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#nickname")
      self.elements["atom:entry"].add_element "apps:nickname", {"name" => name} 
      return self
    end
 
    # adds <gd:who> in the message body.
    def about_who(email)
      self.elements["atom:entry"].add_element "gd:who", {"email" => email } 
      return self
    end
  end
end
