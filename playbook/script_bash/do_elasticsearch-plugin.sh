#!/bin/bash
es_init="es"
limit=""
while getopts 'i:s:' OPTION
do
  case "$OPTION" in
    i)
      #echo "i： $OPTARG"
	  es_init=$OPTARG
      ;;
    s)
      #echo "s： $OPTARG"
	  p_limit="--limit $OPTARG"
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
            python3 /root/yogoo_es_ansible/ansible-playbook  -i ../inventory/$es_init  $p_limit ../playbooks/elasticsearch-plugin.yml -e 'ansible_python_interpreter=/usr/bin/python3'
            ;;
        *)
            echo "cancel"
            ;;
    esac
}

should_execute



 