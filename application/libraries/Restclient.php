<?php

defined('BASEPATH') OR exit('No direct script access allowed');

class Restclient {

    function get($api, $array = null) {
        if ($array == null) {
            $curl_handle = curl_init();
            curl_setopt($curl_handle, CURLOPT_URL, $api);
            curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
            $buffer = curl_exec($curl_handle);
            return $buffer;
        } else {
            $curl_handle = curl_init();
            curl_setopt($curl_handle, CURLOPT_URL, $api);
            curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($curl_handle, CURLOPT_POSTFIELDS, $array);
            $buffer = curl_exec($curl_handle);
            return $buffer;
        }
    }

    function post($api, $array) {
        $curl_handle = curl_init();
        curl_setopt($curl_handle, CURLOPT_URL, $api);
        curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl_handle, CURLOPT_POST, 1);
        curl_setopt($curl_handle, CURLOPT_POSTFIELDS, $array);
        $buffer = curl_exec($curl_handle);
        return $buffer;
    }

    function put($api, $array) {
        $curl_handle = curl_init();
        curl_setopt($curl_handle, CURLOPT_URL, $api);
        curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl_handle, CURLOPT_POSTFIELDS, http_build_query($array));
        curl_setopt($curl_handle, CURLOPT_CUSTOMREQUEST, "PUT");
        $buffer = curl_exec($curl_handle);
        return $buffer;
    }

    function delete($api, $array) {
        $curl_handle = curl_init();
        curl_setopt($curl_handle, CURLOPT_URL, $api);
        curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($curl_handle, CURLOPT_POSTFIELDS, http_build_query($array));
        curl_setopt($curl_handle, CURLOPT_CUSTOMREQUEST, "DELETE");
        $buffer = curl_exec($curl_handle);
        return $buffer;
    }

}
