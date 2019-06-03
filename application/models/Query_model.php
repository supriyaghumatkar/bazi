<?php

(defined('BASEPATH')) OR exit('No direct script access allowed');

/**
 * Description of Model
 *
 * @author Deepak 
 */
class Query_model extends CI_Model {

    public function __construct() {
        parent::__construct();
    }

    /*     * **  Get Details of Single table************** */

    function get_details($fields = '', $from = '', $where = '', $limit = '', $order_by = '', $group_by = '') {
        $data = array();
        if (!empty($fields)) {
            $this->db->select($fields);
        }
        if (!empty($from)) {
            $this->db->from($from);
        }

        if (!empty($where)) {
            $this->db->where($where);
        }

        if (!empty($limit)) {
            $this->db->limit($limit);
        }

        if (!empty($order_by)) {
            $this->db->order_by($order_by);
        }

        if (!empty($group_by)) {
            $this->db->group_by($group_by);
        }

        $query = $this->db->get();

        $data = $query->result_array();

        return $data;
    }

    function get_all_details($fields = '', $from = '', $join = array(), $where = '', $limit = '', $order_by = '', $group_by = '') {
        $data = array();
        if (!empty($fields)) {
            $this->db->select($fields);
        }
        if (!empty($from)) {
            $this->db->from($from);
        }
        if (!empty($join)) {
            foreach ($join as $table => $joincondition) {
                $join_type = explode(":", $joincondition);
                if (empty($join_type[1])) {
                    $join_type[1] = "INNER";
                }
                $this->db->join($table, $join_type[0], $join_type[1]);
            }
        }
        if (!empty($where)) {
            $this->db->where($where);
        }

        if (!empty($limit)) {
            $this->db->limit($limit);
        }

        if (!empty($order_by)) {
            $this->db->order_by($order_by);
        }

        if (!empty($group_by)) {
            $this->db->group_by($group_by);
        }

        $query = $this->db->get();

        $data = $query->result_array();

        return $data;
    }

    function insert($table_name, $data) {

        $success = $this->db->insert($table_name, $data);
        if ($success) {
            return $this->db->insert_id();
        } else {
            return FALSE;
        }
    }

    function update($table_name, $data, $where = array()) {

        if (count($where)) {
            $this->db->where($where);
        }
        return $this->db->update($table_name, $data);
    }

    function delete($table_name, $where = array()) {

        if (count($where)) {
            $this->db->where($where);
        }
        return $this->db->delete($table_name);
    }

}
