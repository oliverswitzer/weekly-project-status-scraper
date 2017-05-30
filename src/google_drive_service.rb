require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class GoogleDriveService
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Drive API Ruby Quickstart'
  CLIENT_SECRETS_PATH = File.join(Dir.home, '.credentials', 'client_secret.json')
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials', 'drive-ruby-quickstart.yaml')
  SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

  def initialize
    @_drive_v3_service = Google::Apis::DriveV3::DriveService.new
    @_drive_v3_service.authorization = get_credentials
  end

  def list_files(*params)
    @_drive_v3_service.list_files(*params)
  end

  def update_file(*params)
    @_drive_v3_service.update_file(*params)
  end

  def export_file(*args)
    @_drive_v3_service.export_file(*args)
  end

  def get_credentials
    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials

    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the resulting code after authorization'
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end
end
