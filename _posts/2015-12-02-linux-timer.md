---
layout: post
title: linux一种定时器的实现
category: linux
---

linux一种定时器的实现

<!-- more -->

使用posix定时器，将SIGUER1注册到定时器中，回调时使用管道通信达到epoll事件监听的目的。

	#include <iostream>
	using namespace std;

	#include <sys/epoll.h>
	#include <stdio.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <signal.h>
	#include <time.h>
	#include <string.h>
	#include <unistd.h>
	
	#define EPOLL_MAX 256
	#define EPOLL_EVENTS_COUNT 20
	#define TIMER_ID 100
	
	typedef void *EpollCBFunc(int fd, int events, void *arg);
	struct epoll_callback
	{
	  int fd;
	  int timeout;
	  EpollCBFunc *func;
	};
	
	int pipefd[2];
	void signal_func(int signo)
	{
	  cout << __func__ << __LINE__ << endl;
	  static int a;
	  write(pipefd[1], &a, sizeof(int));
	  a ++;
	}
	void *timeout_func(int fd, int events, void *arg)
	{
	  if (events & EPOLLIN)
	  {
	    int a = 0;
	    read(fd, &a, sizeof(int));
	    cout << __func__ << __LINE__ << "a = " << a << ",fd = "<< fd << endl;
	  }
	}
	int main(int argc, char **argv)
	{
	  int ret = -1;
	  int epoll_fd = epoll_create(EPOLL_MAX);
	  if (epoll_fd < 0)
	  {
	    perror("epoll_create");
	    return -1;
	  }
	  struct epoll_event events[20];
	
	  ret = socketpair(AF_UNIX, SOCK_STREAM, 0, pipefd);
	  if (ret < 0)
	  {
	    perror("socketpair");
	    return -1;
	  }
	
	  struct epoll_event ev;
	  struct epoll_callback ec;
	  ec.func = timeout_func;
	  ec.fd = pipefd[0];
	  ev.data.ptr = (void*)&ec;
	  ev.events = EPOLLIN;
	  cout << "pipefd[0] = " << pipefd[0] << ",pipefd[1] = " << pipefd[1]  << endl;
	  ret = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, pipefd[0], &ev);
	  if (ret < 0)
	  {
	    perror("epoll_ctl");
	    return ret;
	  }
	
	  struct sigevent sev;
	  timer_t timer_id;
	  sev.sigev_notify = SIGEV_SIGNAL;
	  sev.sigev_signo = SIGUSR1;
	  sev.sigev_value.sival_int = TIMER_ID;
	  ret = timer_create(CLOCK_MONOTONIC, &sev, &timer_id);
	  if (ret < 0)
	  {
	    perror("timer_create");
	    return ret;
	  }
	
	  signal(SIGUSR1,signal_func);
	
	  struct itimerspec its;
	  memset(&its, 0, sizeof(its));
	  its.it_interval.tv_sec = 1;
	  its.it_value.tv_sec = 1;
	  ret = timer_settime(timer_id, 0, &its, NULL);
	  if (ret < 0)
	  {
	    perror("timer_settime");
	    return ret;
	  }
	
	
	  while (true)
	  {
	    int nfds = epoll_wait(epoll_fd, events, EPOLL_EVENTS_COUNT, -1);
	    for (int i=0; i<nfds; ++i)
	    {
	      struct epoll_callback *pec = (struct epoll_callback*)events[i].data.ptr;
	      pec->func(pec->fd, events[i].events, pec);
	    }
	  }
	  return 0;
	}

