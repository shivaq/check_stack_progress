# Default profile executing aws cli
DEFAULT_PROFILE=${1:-sls_admin_role}


STACK_TO_CHECK=${2:-Sg}


# Check No updates are to be performed.
ret_val=$?
if [ $ret_val -eq 255 ];then
    echo "There is nothing to be updated."
    exit
fi

while true
do

    # Get stack status
    test=$(aws cloudformation describe-stack-events \
        --profile $DEFAULT_PROFILE \
        --stack-name $STACK_TO_CHECK \
        --max-items 1)
    stack_event="$(echo $test | jq '."StackEvents"[0]."ResourceStatus"'| tr -d '""')"
    event_reason="$(echo $test | jq '."StackEvents"[0]."ResourceStatusReason"'| tr -d '""')"
    logical_id="$(echo $test | jq '."StackEvents"[0]."LogicalResourceId"'| tr -d '""')"

    echo "$logical_id is $stack_event because $event_reason"

    # Check stack status
    if [ $stack_event = "UPDATE_ROLLBACK_COMPLETE" ] || [ $stack_event = "UPDATE_COMPLETE" ];then
        echo "Yes $stack_event"
        if [ $logical_id = $STACK_TO_CHECK ];then
            echo "Stack change is finished"
            exit
        fi
    fi
    sleep 10s

done
