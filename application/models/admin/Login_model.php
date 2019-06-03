<?php (defined('BASEPATH')) OR exit('No direct script access allowed');
/**
 * Description of Model
 *
 * 
 */
class Login_model extends CI_Model {
	
    public function __construct() {
        parent::__construct();
		
    }
	
    function get_client_detail($client=Null)
    {
    	    $where = array('client_code'=>$client,'cm.is_active'=>'1');
			$join  = array("tbl_client_config_mst as ccm"=>"ccm.client_id=cm.client_id");
		    $client_detail_conf = $this->query->get_all_details('*','tbl_client_mst as cm',$join,$where);
		   	//log_message("error", $this->db->last_query());	
		   	if(is_array($client_detail_conf) && !empty($client_detail_conf))
		   	{
		   		return $client_detail_conf;
		   	}


    }	

	function loginMe($email,$password)
    {
        $where = array('email'=>$email,'status'=>'1');		
		$user = $this->query->get_details('*','admin_user',$where);
        if(!empty($user)){
        	$passwordinput=md5($password);
        	$user_password=$user[0]['password'];
            if($passwordinput===$user_password){
                return $user;
            } else {

                return array();
            }
        } else {
            return array();
        }
    }
}
