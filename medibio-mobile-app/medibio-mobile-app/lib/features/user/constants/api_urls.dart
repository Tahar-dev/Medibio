class ApiUrls {

  static const GET_ALL_USER_URL = 'http://192.168.1.28:8888/technicians/';

  static const LOGIN_URL = 'http://192.168.1.28:8888/technicians/login';

  static const GET_INTERVENTION_BY_USER_NAME_URL =  'http://192.168.1.28:4002/api/interventions/technician?technicianname=';

  static const FETCH_PARC_OF_ITV_URL = 'http://192.168.1.28:4002/api/parcs/id?interventions=';

  static const FETCH_ALL_PARCS_URL = 'http://192.168.1.28:4002/api/parcs';

  static const GET_ALL_INTERVENTIONS_URL = 'http://192.168.1.28:4002/api/interventions/technician?technicianname=';

  static const FETCH_ALL_ARTICLES_URL = 'http://192.168.1.28:4002/api/articles';

  static const SEND_EMAIL_URL = 'http://192.168.1.28:3100/email/send';

  static const UPDATE_ITV_URL = 'http://192.168.1.28:4002/api/interventions/send-intervention-to-sage'; //UPDATE IN SAGE X3

  static const UPDATE_ITV_URL_NEST = 'http://192.168.1.28:4002/api/interventions/replaceOrCreate2'; //UPDATE IN NEST JS
  
}
