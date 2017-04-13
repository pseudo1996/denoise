#include "AdaBoost.h"
#include <iostream>
using std::cout;

vector<matched_patch> block_match(const Mat& image, int patchNum, const Mat& patch, int rstep, int cstep) {

	//输入：全局图像image，匹配块的数目patchNum，参考块patch
	//输出：包含patchNum个matched_patch的vector


	//全局图像与待匹配块的尺寸
	int prs = patch.size().height, pcs = patch.size().width;
	int rs = image.size().height, cs = image.size().width;

	//为了加速，块匹配在全局的步进为滑动块大小的一半
	int rbnd = rs - prs + 1, cbnd = cs - pcs + 1;	//滑动块边界

	int vec_size = ((rs - prs) / rstep + 1)*((cs - pcs) / cstep + 1);
	//存放滑动过程中所有的patch信息
	vector<matched_patch> sp(vec_size);

	int index = 0;
	//滑动并计算距离
	for (int i = 0; i < rbnd; i+=rstep) {
		for (int j = 0; j < cbnd; j+=cstep) {
			sp[index].xpos = i; sp[index].ypos = j;
			sp[index].distance = cv::norm(patch - image(cv::Rect(i, j, prs, pcs)))/(prs*pcs);
			++index;
		}
	}
	std::sort(sp.begin(), sp.end());

	//取距离最小的patchNum个
	vector<matched_patch> mps = vector<matched_patch>(sp.begin(), sp.begin() + patchNum);

	return mps;
}

Mat group(const Mat& image, const vector<matched_patch>& mp, int prs, int pcs) {

	//输入：全局图像image, 包含匹配块信息的vector;mp, 匹配块的尺寸prs与pcs
	//输出：所有匹配块组成的矩阵patch_group（每个匹配块按列连接成列向量）
	int rows = prs*pcs, cols = mp.size();
	Mat patch_group(rows, cols, CV_64F);
	for (int i = 0; i != cols; ++i) {
		image(cv::Rect(mp[i].xpos, mp[i].ypos, prs, pcs)).clone().reshape(0, rows).copyTo(patch_group.col(i));	//image(Range)只是创建了ROI的一个引用，必须将它clone一下
	}
	return patch_group;
}

Mat solve_wnnm(const Mat& pg, double noise_var, double c, double eps) {

	//输入：所有匹配块组成的矩阵pg， 噪声方差nvar， 参数c， 防止除以零的参数eps
	//输出：wnnm方法估计出的矩阵

	//类型转换，因为奇异值分解会出现浮点数
	int rows = pg.size().height, cols = pg.size().width;
	Mat U, S, Vt;
	cv::SVD::compute(pg, S, U, Vt, cv::SVD::FULL_UV);	//将U和V补充成酉矩阵，默认情况下不是
	//S已经是奇异值组成的列向量

	//估计干净patch的奇异值向量
	Mat sigma_est = S.clone();
	int patchNum = cols;
	double nvar = noise_var / 255.0;	//相应地，噪声方差归一化到[0, 1]
	for (double &p : cv::Mat_<double>(sigma_est)) {
		double temp = sqrt(MAX(p*p - patchNum*nvar, 0));
		p = temp;
	}//需要使用向量化来改进速度！！

	 //权值计算
	Mat weight = sigma_est.clone();
	for (double &p : cv::Mat_<double>(weight)) {
		double temp = c*sqrt(patchNum) / (p + eps);
		p = temp;
	}//需要使用向量化来改进速度！！

	 //门限判决矩阵计算
	Mat Sw_diag = S - weight;
	for (double &p : cv::Mat_<double>(Sw_diag)) {
		double temp = MAX(p, 0);
		p = temp;
	}//需要使用向量化来改进速度！！
	Mat Sw = Mat(rows, cols, CV_64F, cv::Scalar(0));

	for (int i = 0; i != cols; ++i) Sw.at<double>(i, i) = Sw_diag.at<double>(i);

	return U*Sw*Vt;

}

Mat aggregate(const Mat& dist, const Mat& est, double h, int prs) {	//该函数需要使用向量化来改进速度！！

	//输入：dist是block_match返回的vector元素的distance组成的Mat，需要显式转换
	//		wnnm估计出的矩阵est，调节聚合的参数h
	//输出：去噪后的patch:deno_patch

	//计算权值
	Mat weight = dist.clone();	//为了运算简便，这里要求dist，weight是列向量！
	double sum = 0;
	for (double &p : cv::Mat_<double>(weight)) {
		double temp = exp(-p*p / h);
		sum += temp;
		p = temp;
	}//需要使用向量化来改进速度！！

	for (double &p : cv::Mat_<double>(weight)) {
		double temp = p / sum;
		p = temp;
	}//需要使用向量化来改进速度！！

	 //这一句是矩阵运算的结果，可自行验证
	Mat deno_vec = est*weight;
	return deno_vec.reshape(0, prs);	//返回去噪后的块（注意是块！），范围[0, 1]
}

double cal_rhoK(const Mat& prim_patch, const Mat& deno_patch, double c, double noise_var) {

	//输入:最开始未去噪图像中对应的patch：prim_patch， 去噪后的deno_patch，调节参数c
	//输出：反馈系数rhoK

	double dp_norm = cv::norm(deno_patch);
	Mat diff = prim_patch - deno_patch;

	diff.reshape(0, 1);// 将diff转为列向量，便于cal_var的计算
	double nvar = noise_var / 255.0;
	double resi_en = c*abs(nvar - cal_var(diff));
	double rhoK = dp_norm / (dp_norm + sqrt(MAX(dp_norm*dp_norm - resi_en, 0)));
	return rhoK;
}

double cal_var(const Mat& m) {

	//说明：计算矩阵元素方差的小函数
	//要求：m是行/列向量

	int elem_num = m.size().height;	//向量元素个数
	double mean = m.dot(Mat::ones(m.size(), m.type())) / elem_num;
	return (m.dot(m) - elem_num*mean*mean) / (elem_num - 1);

}