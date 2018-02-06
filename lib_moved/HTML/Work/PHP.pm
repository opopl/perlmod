
package HTML::Work::PHP;

use strict;
use warnings;

use warnings;
use strict;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = '0.01';
@ISA     = qw(Exporter);

@EXPORT      = qw();

###export_vars_scalar
my @ex_vars_scalar=qw(
);
###export_vars_hash
my @ex_vars_hash=qw(
);
###export_vars_array
my @ex_vars_array=qw(
	$php_net_subs
);

%EXPORT_TAGS = (
###export_funcs
'funcs' => [qw( 

)],
'vars'  => [ @ex_vars_scalar,@ex_vars_array,@ex_vars_hash ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'funcs'} }, @{ $EXPORT_TAGS{'vars'} } );
our @EXPORT  = qw( );
our $VERSION = '0.01';

our $php_net_subs ={
###subs_array
	array => [qw(
		array_change_key_case array_chunk array_column array_combine
		array_count_values array_diff_assoc array_diff_key array_diff_uassoc
		array_diff_ukey array_diff array_fill_keys array_fill array_filter
		array_flip array_intersect_assoc array_intersect_key array_intersect_uassoc
		array_intersect_ukey array_intersect array_key_exists array_keys array_map
		array_merge_recursive array_merge array_multisort array_pad array_pop
		array_product array_push array_rand array_reduce array_replace_recursive
		array_replace array_reverse array_search array_shift array_slice
		array_splice array_sum array_udiff_assoc array_udiff_uassoc array_udiff
		array_uintersect_assoc array_uintersect_uassoc array_uintersect
		array_unique array_unshift array_values array_walk_recursive array_walk
		array arsort asort compact count current each end extract in_array
		key_exists key krsort ksort list natcasesort natsort next pos prev range
		reset rsort shuffle sizeof sort uasort uksort usort
	)],
	postgresql => [qw(
		pg_affected_rows
		pg_cancel_query
		pg_client_encoding
		pg_close
		pg_connect
		pg_connect_poll
		pg_connection_busy
		pg_connection_reset
		pg_connection_status
		pg_consume_input
		pg_convert
		pg_copy_from
		pg_copy_to
		pg_dbname
		pg_delete
		pg_end_copy
		pg_escape_bytea
		pg_escape_identifier
		pg_escape_literal
		pg_escape_string
		pg_execute
		pg_fetch_all
		pg_fetch_all_columns
		pg_fetch_array
		pg_fetch_assoc
		pg_fetch_object
		pg_fetch_result
		pg_fetch_row
		pg_field_is_null
		pg_field_name
		pg_field_num
		pg_field_prtlen
		pg_field_size
		pg_field_table
		pg_field_type
		pg_field_type_oid
		pg_flush
		pg_free_result
		pg_get_notify
		pg_get_pid
		pg_get_result
		pg_host
		pg_insert
		pg_last_error
		pg_last_notice
		pg_last_oid
		pg_lo_close
		pg_lo_create
		pg_lo_export
		pg_lo_import
		pg_lo_open
		pg_lo_read
		pg_lo_read_all
		pg_lo_seek
		pg_lo_tell
		pg_lo_truncate
		pg_lo_unlink
		pg_lo_write
		pg_meta_data
		pg_num_fields
		pg_num_rows
		pg_options
		pg_parameter_status
		pg_pconnect
		pg_ping
		pg_port
		pg_prepare
		pg_put_line
		pg_query
		pg_query_params
		pg_result_error
		pg_result_error_field
		pg_result_seek
		pg_result_status
		pg_select
		pg_send_execute
		pg_send_prepare
		pg_send_query
		pg_send_query_params
		pg_set_client_encoding
		pg_set_error_verbosity
		pg_socket
		pg_trace
		pg_transaction_status
		pg_tty
		pg_unescape_bytea
		pg_untrace
		pg_update
		pg_version
	)],
	exec => [qw(
		escapeshellarg
		escapeshellcmd
		exec
		passthru
		proc_close
		proc_get_status
		proc_nice
		proc_open
		proc_terminate
		shell_exec
		system
	)],
	session  => [qw(
				session_abort
				session_cache_expire
				session_cache_limiter
				session_commit
				session_create_id
				session_decode
				session_destroy
				session_encode
				session_gc
				session_get_cookie_params
				session_id
				session_is_registered
				session_module_name
				session_name
				session_regenerate_id
				session_register_shutdown
				session_register
				session_reset
				session_save_path
				session_set_cookie_params
				session_set_save_handler
				session_start
				session_status
				session_unregister
				session_unset
				session_write_close
	)],
	funchand  => [qw(
			call_user_func_array
			call_user_func
			create_function
			forward_static_call_array
			forward_static_call
			func_get_arg
			func_get_args
			func_num_args
			function_exists
			get_defined_functions
			register_shutdown_function
			register_tick_function
			unregister_tick_function
	)],
###subs_vars
	vars => [qw(
		intval
		boolval
		debug_zval_dump
		doubleval
		empty
		floatval
		get_defined_vars
		get_resource_type
		gettype
		import_request_variables
		intval
		is_array
		is_bool
		is_callable
		is_double
		is_float
		is_int
		is_integer
		is_iterable
		is_long
		is_null
		is_numeric
		is_object
		is_real
		is_resource
		is_scalar
		is_string
		isset
		print_r
		serialize
		settype
		strval
		unserialize
		unset
		var_dump
		var_export


	)],
###subs_opt
	opt => [qw(
				assert
				assert_options
				cli_get_process_title
				cli_set_process_title
				dl
				extension_loaded
				gc_collect_cycles
				gc_disable
				gc_enable
				gc_enabled
				gc_mem_caches
				get_cfg_var
				get_current_user
				get_defined_constants
				get_extension_funcs
				get_include_path
				get_included_files
				get_loaded_extensions
				get_magic_quotes_gpc
				get_magic_quotes_runtime
				get_required_files
				get_resources
				getenv
				getlastmod
				getmygid
				getmyinode
				getmypid
				getmyuid
				getopt
				getrusage
				ini_alter
				ini_get
				ini_get_all
				ini_restore
				ini_set
				magic_quotes_runtime
				main
				memory_get_peak_usage
				memory_get_usage
				php_ini_loaded_file
				php_ini_scanned_files
				php_logo_guid
				php_sapi_name
				php_uname
				phpcredits
				phpinfo
				phpversion
				putenv
				restore_include_path
				set_include_path
				set_magic_quotes_runtime
				set_time_limit
				sys_get_temp_dir
				version_compare
				zend_logo_guid
				zend_thread_id
				zend_version
	)],
###subs_pcre
	pcre => [qw(
				preg_filter
				preg_grep
				preg_last_error
				preg_match_all
				preg_match
				preg_quote
				preg_replace_callback_array
				preg_replace_callback
				preg_replace
				preg_split
	)],
###subs_filesystem
	filesystem => [qw(
				basename
				chgrp
				chmod
				chown
				clearstatcache
				copy
				delete
				dirname
				disk_free_space
				disk_total_space
				diskfreespace
				fclose
				feof
				fflush
				fgetc
				fgetcsv
				fgets
				fgetss
				file_exists
				file_get_contents
				file_put_contents
				file
				fileatime
				filectime
				filegroup
				fileinode
				filemtime
				fileowner
				fileperms
				filesize
				filetype
				flock
				fnmatch
				fopen
				fpassthru
				fputcsv
				fputs
				fread
				fscanf
				fseek
				fstat
				ftell
				ftruncate
				fwrite
				glob
				is_dir
				is_executable
				is_file
				is_link
				is_readable
				is_uploaded_file
				is_writable
				is_writeable
				lchgrp
				lchown
				link
				linkinfo
				lstat
				mkdir
				move_uploaded_file
				parse_ini_file
				parse_ini_string
				pathinfo
				pclose
				popen
				readfile
				readlink
				realpath_cache_get
				realpath_cache_size
				realpath
				rename
				rewind
				rmdir
				set_file_buffer
				stat
				symlink
				tempnam
				tmpfile
				touch
				umask
				unlink
)],
}
;



1;
 

