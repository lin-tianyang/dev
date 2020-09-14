#!/bin/bash

case $1 in
        ALL_STATE)
                result=`ss  state ALL|  grep -v Send-Q | wc -l`
                echo $result
        ;;
        LISTEN)     #表示服务器端的某个SOCKET处于监听状态，可以接受连接了
                result=`ss  state  LISTENING |  grep -v Send-Q | wc -l`
                echo $result
        ;;
        SYN_SENT)   #客户端调用connect，发送一个SYN请求建立一个连接，在发送连接请求后等待匹配的连接请求，此时状态为SYN_SENT.
                result=`ss  state  syn-sent |  grep -v Send-Q |wc -l`
                echo $result
        ;;
        SYN_RECV)   #在收到和发送一个连接请求后，等待对方对连接请求的确认，当服务器收到客户端发送的同步信号时，将标志位ACK和SYN置1发送给客户端，此时服务器端处于SYN_RCVD状态，如果连接成功了就变为ESTABLISHED，正常情况下SYN_RCVD状态非常短暂态
                result=`ss  state  SYN-RECV |  grep -v Send-Q |wc -l`
                echo $result
        ;;
        ESTABLISHED) #ESTABLISHED状态是表示两台机器正在传输数据。
                result=`ss  state  ESTABLISHED |  grep -v Send-Q |wc -l`
                echo $result
        ;;      
        FIN-WAIT-1)  #等待远程TCP连接中断请求，或先前的连接中断请求的确认，主动关闭端应用程序调用close，TCP发出FIN请求主动关闭连接，之后进入FIN_WAIT1状态。
                result=`ss state FIN-WAIT-1  | grep -v Send-Q | wc -l`
                echo $result
        ;;
        FIN-WAIT-2)  #从远程TCP等待连接中断请求，主动关闭端接到ACK后，就进入了FIN-WAIT-2 .这是在关闭连接时，客户端和服务器两次握手之后的状态，是著名的半关闭的状态了，在这个状态下，应用程序还有接受数据的能力，但是已经无法发送数据，但是也有一种可能是，客户端一直处于FIN_WAIT_2状态，而服务器则一直处于WAIT_CLOSE状态，而直到应用层来决定关闭这个状态。 
                result=`ss state FIN-WAIT-2  | grep -v Send-Q | wc -l`
                echo $result
        ;;
        CLOSE-WAIT)  #等待从本地用户发来的连接中断请求 ，被动关闭端TCP接到FIN后，就发出ACK以回应FIN请求(它的接收也作为文件结束符传递给上层应用程序),并进入CLOSE_WAIT
                result=`ss  state  CLOSE-WAIT |  grep -v Send-Q | wc -l`
                echo $result
        ;;        
        CLOSING)    #等待远程TCP对连接中断的确认
                result=`ss  state  CLOSING |  grep -v Send-Q | wc -l`
                echo $result
        ;;
        LAST-ACK)  #等待原来的发向远程TCP的连接中断请求的确认,被动关闭端一段时间后，接收到文件结束符的应用程序将调用CLOSE关闭连接,TCP也发送一个 FIN,等待对方的ACK.进入LAST-ACK。
                result=`ss  state  LAST-ACK |  grep -v Send-Q |wc -l`
                echo $result
        ;;
        TIME-WAIT)   #在主动关闭端接收到FIN后，TCP就发送ACK包，并进入TIME-WAIT状态,等待足够的时间以确保远程TCP接收到连接中断请求的确认,很大程度上保证了双方都可以正常结束,但是也存在问题，须等待2MSL时间的过去才能进行下一次连接。
                result=`ss  state  TIME-WAIT |  grep -v Send-Q |wc -l`
                echo $result
        ;;
        closed)     #被动关闭端在接受到ACK包后，就进入了closed的状态，连接结束，没有任何连接状态。
                result=`ss  state  closed |  grep -v Send-Q | wc -l`
                echo $result        
        ;;
        IO-util)     #io10秒内情况,没有值则取0
                result=`iostat -x 1 5 | grep -Ev '^L|^a|^D|^$' | awk '{if ($14 >70) print $14 ;else print 0}' |sort -r | head -n 1`
                echo $result        
        ;;
        cache_free)  #内存，暂时没用
                free=`cat /proc/meminfo | grep MemFree  | awk  '{print $2}'`
                buffers=`cat /proc/meminfo | grep Buffers  | awk  '{print $2}'`
                cached=`cat /proc/meminfo | grep Cached  | awk  '{sum += $2};END {print sum}'`
                total=`cat /proc/meminfo  | grep MemTotal | awk '{print $2}'`
                result=`echo "$free $buffers $cached $total" | awk '{ print int( (($1+$2+$3)/$4)*100)}'`
                echo $result
        ;;

esac
