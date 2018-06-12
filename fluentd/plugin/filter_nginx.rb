# -*- coding: UTF-8 -*-

require 'fluent/filter'

module Fluent
  class NginxFilter < Filter
    Fluent::Plugin.register_filter('nginx', self)


    def configure(conf)
      super
      # do the usual configuration here
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter_stream(tag, es)
        new_es = MultiEventStream.new
	es.each { |time, record|
        begin
		new_record = record.clone
		if(record['method']!='GET' and record['method']!='logmanage')
			if(record['method']=="POST")
	             		new_record['method'] ='创建'
	        	elsif(record['method']=="DELETE")
	             		new_record['method'] ='删除'
			elsif(record['method']=="PUT" or record['method']=='PATCH')
	             		if(record['method'] == "PATCH" and record['uri'] =~ /^\/.*deployments.*/)
	                		new_record['method']='调整实例'
	             		else
	             			new_record['method']='修改'
	             		end
	        	end
	
	
		
			if(record['status']=='200' or record['status']=='201' or record['status']=='204')
				new_record['status'] = '成功'
			else
	                	new_record['status']=  '失败'
			end
	
	    		if(record['uri'] =~ /apis\/cmss\.com\/v1\// )
				uri = record['uri'].split("/")
	    
				if(uri[4]=='user')
					if(uri[-1]=='password')
						new_record['opobj']='密码'
						new_record['detail']='用户'+uri[-2]+"修改密码"
						result = new_record
						new_es.add(time,result)
					end

					if(uri[-1]=='groups')
						 new_record['opobj'] ='用户组'
						if(new_record['method']=='修改')
							new_record['method'] ='增加'
							new_record['detail'] ='用户组'+new_record['method']+'用户'+uri[-2]
							result = new_record
							new_es.add(time,result)
						else
							new_record['detail']='用户组'+new_record['method']+'用户'+uri[-2]
							result = new_record
							new_es.add(time,result)
						end
					end

					if(uri[-1]=='user')
						new_record['opobj']='用户'
						new_record['detail']='用户名'+new_record['body']
						result = new_record
						new_es.add(time,result)
					end

					if(uri[-1]!='password' and uri[-1]!='groups' and uri[-1]!= 'user' )
						new_record['opobj']='用户'
	                                	new_record['detail']='用户名'+uri[-1]
						result = new_record
						new_es.add(time,result)
					end
				end	
				
				if(uri[4]=='group')
					if(uri[-1]=='group')
						new_record['opobj']='用户组'
	                                	new_record['detail']='用户组'+new_record['body']
						result = new_record
					elsif(uri[-2]=='group')
						new_record['opobj']='用户组'
	                                	new_record['detail']=new_record['method']+'用户组'+uri[-1]
						result = new_record
					elsif(uri[-3]=='group')
						if(new_record['method']=='修改')
							new_record['method']='增加'
						end
						new_record['opobj']='用户组'
	                                	new_record['detail']='用户组'+uri[-2]+new_record['method']+uri[-1]
						result = new_record
					end
				 	new_es.add(time,result)
				end
				
	
				if(uri[4]=='resource')
					if(uri[-1]=='resource')
						new_record['opobj']='权限资源'
	                                	new_record['detail']=new_record['method']+'权限资源'
						result = new_record
					else
	                                	new_record['opobj']='权限资源'
	                                	new_record['detail']=new_record['method']+'权限资源'+uri[-1]
						result = new_record
					end
				 	new_es.add(time,result)
				end
	
	
				if(uri[4]=='rule')
					if(uri[-1]=='rule')
	                                	new_record['opobj']='权限项'
	                                	new_record['detail']='权限项'+new_record['body']
						result = new_record
					elsif(uri[-2]=='rule')
	                                	new_record['opobj']='权限项' 
	                                	new_record['detail']='权限项'+uri[-1]
						result = new_record
	  				elsif(uri[-3]=='rule')
	                                	new_record['opobj']='权限项' 
	                                	new_record['detail']='权限项'+uri[-2]+new_record['method']+'权限资源'
						result = new_record
					elsif(uri[-4]=='rule')
	                                	new_record['opobj']='权限项' 
	                                	new_record['detail']='权限项'+uri[-3]+new_record['method']+'权限资源'+uri[-1]
						result = new_record
					end
					new_es.add(time,result)
				end
	
	
				if(uri[4]=='role')
					if(uri[-1]=='role')
	                                	new_record['opobj']='角色' 
	                                	new_record['detail']='角色'+new_record['body']
						result = new_record
	                        	elsif(uri[-2]=='role')
	                                	new_record['opobj']='角色'
	                                	new_record['detail']='角色ID:'+uri[-1]
						result = new_record
	                        	elsif(uri[-3]=='role')
	                                	new_record['opobj']='角色'
	                                	new_record['detail']='角色(ID:'+uri[-2]+')添加权限'
						result = new_record
	                        	elsif(uri[-4]=='role')
	                                	new_record['opobj']='角色'
	                                	new_record['detail']='角色(ID:'+uri[-3]+')'+new_record['method']+'权限(ID:'+uri[-1]+')'
						result = new_record
	                        	end
	     				new_es.add(time,result)
				end

				if(uri[4]=='authority')
					if(uri[-1]=='authority')
	                                	new_record['opobj']='赋权' 
	                                	new_record['detail']='域/用户(组):'+new_record['body']
						new_record['method']='添加'
						result = new_record
	                        	elsif(uri[-2]=='authority')
	                                	new_record['opobj']='赋权'
	                                	new_record['detail']='赋权ID:'+uri[-1]
						result = new_record
	                        	elsif(uri[-4]=='authority')
						if(uri[-2]=='role')
							new_record['opobj']='赋权'
							new_record['detail']='角色ID:('+uri[-1]+')'+new_record['method']+'权限(ID:'+uri[-3]+')'
							result = new_record
						else
							if(uri[-1]=='0')
								new_record['method'] ='关闭'
								new_record['opobj'] = '赋权'
								new_record['detail'] = '权限ID:'+uri[-3]
								result = new_record
							else
								new_record['method'] ='激活'
	                                                	new_record['opobj'] = '赋权'
	                                                	new_record['detail'] = '权限ID:'+uri[-3]
								result = new_record
							end					
						end
					end
					new_es.add(time,result)
 	 	  		end

				if(uri[4]=='login')
					new_record['method']='登录'
					result = new_record
	              		 	new_es.add(time,result) 
				end
			end
	
			if (record['uri'] =~ /conductor\/api\/v1\//)
				uri = record['uri'].split('/')
				if(uri[4]=='appdeploymentfromfile')
					body =record['body'].split(':')
					if(body[1]=='Deployment')
						new_record['opobj']='无状态应用'
						new_record['detail']='应用名称:'+body[0]
						result = new_record
					elsif(body[1]=='DaemonSet')
						new_record['opobj']='系统应用'
						new_record['detail']='应用名称:'+body[0]
						result = new_record
					else
						new_record['opobj']='有状态应用'
						new_record['detail']='应用名称:'+body[0]
						result = new_record
					end
				 	new_es.add(time,result)
				end

				if(uri[5]=='deployment')
					new_record['opobj']='无状态应用'
					new_record['detail']='应用名称:'+uri[-1]
					result = new_record
				 	new_es.add(time,result)
				end
	
				if(uri[5]=='daemonset')
	                        	new_record['opobj']='系统应用'
	                        	new_record['detail']='应用名称:'+uri[-1]
					result = new_record
				 	new_es.add(time,result)
				end

				if(uri[5]=='statefulset')
	                        	new_record['opobj']='有状态应用'
	                        	new_record['detail']='应用名称:'+uri[-1]
					result = new_record
				 	new_es.add(time,result)
				end

				if(uri[5]=='service')
	                        	new_record['opobj']='服务'
	                        	new_record['detail']='服务名称:'+uri[-1]
					result = new_record
				 	new_es.add(time,result)
				end

		        	if(uri[5]=='configmap')
					new_record['opobj']='配置集'
					if(new_record['method']=='创建')
						new_record['detail']='配置名称:'+record['body']
						result = new_record
					else
						new_record['detail']='配置名称:'+uri[-1]
						result = new_record
					end
					new_es.add(time,result)
				end

				if(uri[5]=='secret')
					new_record['opobj']='秘钥集'
	                                if(new_record['method']=='创建')
	                                        new_record['detail']='秘钥名称:'+record['body']
						result = new_record
	                                else
	                                        new_record['detail']='秘钥名称:'+uri[-1]
						result = new_record
	                                end
					new_es.add(time,result)
				end

				if(uri[5]=='namespace')
					new_record['opobj']='域'
					if(new_record['method']=='创建')
						new_record['detail']='域名称:'+record['body']
						result = new_record
					else
						new_record['detail']='域名称:'+uri[-1]
						result = new_record
					end
				 	new_es.add(time,result)
				end
				if(uri[5]=='ingress')
					new_record['opobj']='路由'
	                        	if(new_record['method']=='创建')
	                                	new_record['detail']='路由名称:'+record['body']
						result = new_record
	                        	else
	                                	new_record['detail']='路由名称:'+uri[-1]
						result = new_record
	                        	end
				 	new_es.add(time,result)
				end
				if(uri[5]=='resourcequota')
					new_record['opobj']='资源配额'
					new_record['detail']='域名称：'+uri[-1]
					result = new_record
					new_es.add(time,result)
				end
			end
			
			if(record['uri']=~ /\/loadbalance\/v1\// )
				uri = record['uri'].split('/')
				if(uri[3]=='ingress')
					new_record['opobj']='路由'
					if(new_record['method']=='创建')
						new_record['detail']='路由名称:'+record['body']
						result = new_record
					else
						new_record['detail']='路由名称:'+uri[-1]
					result = new_record
					end
				 	new_es.add(time,result)
				end
			end

			if(record['uri'] =~ /^\/.*resource\/.*/)
				uri = record['uri'].split('/')
				new_record['opobj']='主机资源'
				new_record['detail']='主机IP:'+uri[-1]
				result = new_record
				new_es.add(time,result)
			end

	        #	if(record['uri'] =~ /^\/.*clusternodes\/.*/)
	        #        	uri = record['uri'].split('/')
	        #        	new_record['opobj']='节点'
	        #        	new_record['detail']='主机IP:'+uri[-1]
		#		result = new_record
		#		new_es.add(time,result)
		#	end

			if(record['uri'] =~ /^\/.*horizontalpodautoscaler.*/)
				 new_record['opobj']='弹性伸缩'
		       		 if(new_record['method']=='创建')
                                                new_record['detail']='弹性伸缩名称:'+record['body']
                                                result = new_record
                                        else
                                                new_record['detail']='弹性伸缩名称:'+uri[-1]
                                                result = new_record
                                 end
				new_es.add(time,result)
			end

			if(record['uri'] =~ /image.*\/registry\/api\/v1/)
                                new_record['opobj']='镜像'
                                uri = record['uri'].split('/')
				if(uri[-1]=='tags')
                                	if(new_record['method']=='创建')
                                        	new_record['method']='回收'
                                        	new_record['detail']='镜像名称:'+ uri[-2]
                                        	result = new_record
                                	elsif(new_record['method']=='修改')
                                        	new_record['method']='还原'
                                        	new_record['detail']='镜像名称:'+ uri[-2]
                                        	result = new_record
                                	end
                        		new_es.add(time,result)
				end

				if(uri[-1]=='star')
					 if(new_record['method']=='创建')
                                                new_record['method']='收藏'
                                                new_record['detail']='镜像名称:'+ uri[-2]
                                                result = new_record
                                        elsif(new_record['method']=='删除')
                                                new_record['method']='取消收藏'
                                                new_record['detail']='镜像名称:'+ uri[-2]
                                                result = new_record
                                        end
                                        new_es.add(time,result)
				end
                        end

                        if(record['uri'] =~ /image\/api\/repositories/ )
                                new_record['opobj'] = '镜像'
                                uri = record['uri'].split('/')
                                 if(new_record['method']='删除')
                                        new_record['detail']='镜像名称:'+ uri[-3]
                                        result = new_record
                                end
                        	new_es.add(time,result)
                        end
		end
	end
	}

	new_es.each{ |time,record|
		begin
			record.delete('uri')
			record['timestamp']=(Time.now.to_f * 1000).to_i
			record['cluster']='cluster-1'
			record['time'] = Time.now.to_s
                        record['lasttime'] = record['lasttime'].to_f
			record.delete('body')
			record['optype']=record['method']
		end
	}
	new_es
    end
  end
end





