<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

if (!function_exists('check_token'))
{
	function check_token($token,$user_id)
	{
       $ci =& get_instance();

	$ci->db->select('*');
        $ci->db->where('user_id', $user_id);
	$ci->db->where('csrf_token', $token);
        return $ci->db->get('users')->row();
		
		
	}
}
