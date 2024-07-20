package com.cleancode.liveness_azure_flutter

import android.content.Context
import android.graphics.Canvas
import android.graphics.Outline
import android.graphics.Path
import android.graphics.RectF
import android.util.AttributeSet
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.view.ViewOutlineProvider
import kotlin.math.roundToInt


/**
 * A [SurfaceView] that can be adjusted to a specified aspect ratio and
 * performs center-crop transformation of input frames.
 */
class AutoFitSurfaceView @JvmOverloads constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyle: Int = 0
) : SurfaceView(context, attrs, defStyle), SurfaceHolder.Callback {

    private var aspectRatio = 0f

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        if (aspectRatio == 0f) {
            setMeasuredDimension(width, height)
        } else {
            val newWidth: Int
            val newHeight: Int
            val actualRatio = 1f
            if (width < height * actualRatio) {
                newHeight = height
                newWidth = (height * actualRatio).roundToInt()
            } else {
                newWidth = width
                newHeight = (width / actualRatio).roundToInt()
            }
            setMeasuredDimension(newWidth, newHeight)
        }
    }

    override fun dispatchDraw(canvas: Canvas) {
        super.dispatchDraw(canvas)
        canvas.clipPath(path)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        val halfWidth = w / 2f
        val halfHeight = h / 2f
        val widthRatio = 0.75f
        val heightRatio = 1.0f
        val ovalWidth = halfWidth * widthRatio
        val ovalHeight = halfHeight * heightRatio
        path.reset()
        path.addOval(halfWidth - ovalWidth, halfHeight - ovalHeight, halfWidth + ovalWidth, halfHeight + ovalHeight, Path.Direction.CW)
        path.close()
    }

    companion object {
        private val TAG = AutoFitSurfaceView::class.java.simpleName
    }

    private val path: Path = Path()

    init {
        outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View?, outline: Outline?) {
                if (view != null && outline != null) {
                    val widthRatio = 1.0f
                    val heightRatio = 0.75f
                    val ovalWidth = (view.measuredWidth / 2) * widthRatio
                    val ovalHeight = (view.measuredHeight / 2) * heightRatio
                    val rect = RectF(
                        (view.measuredWidth / 2 - ovalWidth),
                        (view.measuredHeight / 2 - ovalHeight),
                        (view.measuredWidth / 2 + ovalWidth),
                        (view.measuredHeight / 2 + ovalHeight)
                    )
                    outline.setOval(
                        rect.left.toInt(),
                        rect.top.toInt(),
                        rect.right.toInt(),
                        rect.bottom.toInt()
                    )
                }
            }
        }
        clipToOutline = true
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        // "Not yet implemented"
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        // "Not yet implemented"
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        // "Not yet implemented"
    }
}