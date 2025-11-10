package com.metallic.chiaki.touchcontrols

import android.content.Context
import android.os.Bundle
import android.view.Display
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LiveData
import com.metallic.chiaki.R
import com.metallic.chiaki.stream.StreamViewModel
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.rxkotlin.addTo

class ControllerPresentation(
    context: Context,
    display: Display,
    private val viewModel: StreamViewModel
) : androidx.appcompat.app.AppCompatDialog(context, android.R.style.Theme_Black_NoTitleBar_Fullscreen) {

    private var touchControlsFragment: TouchControlsFragment? = null
    private val compositeDisposable = CompositeDisposable()

    init {
        // 设置Presentation的显示窗口
        window?.let { window ->
            window.addFlags(WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE)
            window.type = WindowManager.LayoutParams.TYPE_APPLICATION_MEDIA
            window.display = display
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContentView(R.layout.presentation_controller)
        
        // 根据设置决定使用哪种控制器类型
        val fragment = if (viewModel.onScreenControlsEnabled.value == true) {
            DefaultTouchControlsFragment()
        } else {
            TouchpadOnlyFragment()
        }
        
        touchControlsFragment = fragment
        
        supportFragmentManager.beginTransaction()
            .replace(R.id.controllerContainer, fragment)
            .commit()
    }
    
    override fun onStart() {
        super.onStart()
        
        touchControlsFragment?.let { fragment ->
            // 订阅控制器状态并传递给主ViewModel
            fragment.controllerState
                .subscribe { controllerState ->
                    viewModel.input.touchControllerState = controllerState
                }
                .addTo(compositeDisposable)
                
            fragment.onScreenControlsEnabled = viewModel.onScreenControlsEnabled
            if(fragment is TouchpadOnlyFragment)
                fragment.touchpadOnlyEnabled = viewModel.touchpadOnlyEnabled
        }
    }
    
    override fun onStop() {
        super.onStop()
        compositeDisposable.clear()
    }
    
    fun supportFragmentManager() = supportFragmentManager
}