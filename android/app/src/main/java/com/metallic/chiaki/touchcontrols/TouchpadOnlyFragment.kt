// SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL

package com.metallic.chiaki.touchcontrols

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import com.metallic.chiaki.databinding.FragmentTouchpadOnlyBinding
import io.reactivex.rxkotlin.Observables.combineLatest

class TouchpadOnlyFragment : TouchControlsFragment()
{
	var touchpadOnlyEnabled: LiveData<Boolean>? = null

	private var _binding: FragmentTouchpadOnlyBinding? = null
	private val binding get() = _binding!!

	override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
		FragmentTouchpadOnlyBinding.inflate(inflater, container, false).let {
			_binding = it
			controllerStateProxy.onNext(
				combineLatest(ownControllerStateSubject, binding.touchpadView.controllerState) { a, b -> a or b }
			)
			it.root
		}

	override fun onViewCreated(view: View, savedInstanceState: Bundle?)
	{
		super.onViewCreated(view, savedInstanceState)
		// 检查是否有viewLifecycleOwner，如果没有则直接设置可见性
		if (::viewLifecycleOwner.isInitialized) {
			touchpadOnlyEnabled?.observe(viewLifecycleOwner, Observer {
				view.visibility = if(it) View.VISIBLE else View.GONE
			})
		} else {
			// 在Presentation中使用时，直接根据设置显示控件
			view.visibility = if(touchpadOnlyEnabled?.value == true) View.VISIBLE else View.GONE
		}
	}

	private fun buttonStateChanged(buttonMask: UInt) = { pressed: Boolean ->
		ownControllerState = ownControllerState.copy().apply {
			buttons =
				if(pressed)
					buttons or buttonMask
				else
					buttons and buttonMask.inv()
		}
	}
}