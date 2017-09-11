package info.scce.pyro.async

import java.lang.annotation.Inherited
import java.lang.annotation.Retention
import java.lang.annotation.Target
import javax.interceptor.InterceptorBinding

@InterceptorBinding
@Target(#[METHOD, TYPE])
@Retention(RUNTIME)
@Inherited
annotation Asynchronous {}
