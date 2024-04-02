#!/bin/bash
es_host="all"
p_limit=""
executestr=""
while getopts 'h:s:' OPTION
do
  case "$OPTION" in
    h)
      #echo "i： $OPTARG"
	    es_host=$OPTARG
      ;;
    s)
      #echo "s： $OPTARG"
	    p_limit=$OPTARG
      ;;
    ?)
      echo "Unknown option: -$OPTARG"
      exit 1
      ;;
  esac

done

should_execute() {
    read -p "Execute the command? (y/n)" answer
    case "$answer" in
        y|yes)
            python3 /root/yogoo_es_ansible/ansible-playbook  -i ../inventory/$es_host ../playbooks/destroy.yml "-e hosts=$p_limit with_data=1"
            ;;
        *)
            echo "cancel"
            ;;
    esac
}
 
should_execute


