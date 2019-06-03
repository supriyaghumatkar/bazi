<?php (defined('BASEPATH')) OR exit('No direct script access allowed');
/**
 * Description of Model
 *
 * 
 */
class Register_model extends CI_Model {
	
    public function __construct() {
        parent::__construct();
		
    }
	
    function get_register_user_detail()
    {
        //$where = array('status' => 'active');
        $user_detail = $this->query->get_details('*','users'); 
        if (is_array($user_detail)) {
            return  $user_detail;
        }


    }	

    function delete_user($user_id)
    {
                $where= array('user_id'=>$user_id);
				//$data = array('status'=>'delete','modify_date'=>date('Y-m-d H:i:s'));
                $tbl_user_mst_delete= $this->query->delete('users',$where);
                if($tbl_user_mst_delete)
                {
                    return $tbl_user_mst_delete;
                }
    }

}
