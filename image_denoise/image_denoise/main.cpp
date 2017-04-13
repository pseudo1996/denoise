#include "AdaBoost.h"
#include <iostream>

/*
#include <vector>
#include <algorithm>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using std::vector;
using cv::Mat;

struct matched_patch {
int xpos;
int ypos;
double distance;
};

inline bool operator<(const matched_patch& mp1, const matched_patch& mp2) {
return mp1.distance < mp2.distance;
};

inline std::ostream& operator<<(std::ostream& out, const matched_patch& mp) {

return out << "xpos: " << mp.xpos << '\t' << "ypos: " << mp.ypos << '\t' << "dist: " << mp.distance << '\n';

}

vector<matched_patch> block_match(const Mat&, int, const Mat&, int, int);

Mat group(const Mat&, const vector<matched_patch>&, int, int);

Mat solve_wnnm(const Mat&, double, double, double);

Mat aggregate(const Mat&, const Mat&, double, int);

double cal_rhoK(const Mat&, const Mat&, double, double);

double cal_var(const Mat&);

*/

using std::cout;

int main() {

	double noise_var = 50;
	Mat lena = cv::imread("E:/Design/denoise/test_pics/50.jpg", cv::ImreadModes::IMREAD_GRAYSCALE);	//����Ҷ�ͼ��
	Mat lena_double;
	lena.convertTo(lena_double, CV_64F, 1.0 / 255.0f);	//��[0, 255]ת��[0, 1]�����ں�������

	int prs = 32, pcs = 32, patch_num = 10;
	Mat ref_patch(prs, pcs, CV_64F);	//���ڴ��滬��ʱ�Ĳο���
	int rs = lena_double.size().height, cs = lena_double.size().width;
	int rbnd = rs - prs + 1, cbnd = cs - pcs + 1;

	Mat deno_image_double = Mat(rs, cs, CV_64F, cv::Scalar(0));	//����point-wise�Ĺ���
	Mat number = Mat(rs, cs, CV_16U, cv::Scalar(0));	//���ڼ�¼ÿ������ʶ��ٴ�

	int rstep = prs / 2, cstep = pcs / 2;	//Ϊ�˼��٣����ȥ��Ĳ���Ϊ�������С��һ��

	int patch_process = ((rs - prs) / rstep + 1)*((cs - pcs) / cstep + 1);	//Ҫ�������ܿ���
	int now = 0;	//�Ѿ���ɵĿ���
	for (int rpos = 0; rpos < rbnd; rpos+=rstep){
		for (int cpos = 0; cpos < cbnd; cpos+=cstep) {

			ref_patch = lena_double(cv::Rect(rpos, cpos, prs, pcs));	//����ʱ�Ĳο���,����
			vector<matched_patch> mps = block_match(lena_double, patch_num, ref_patch, rstep, cstep);	//��¼ƥ���������Լ���Ӧ����
			Mat patch_group = group(lena_double, mps, prs, pcs);	//��ԭʼͼ����ȡ��ƥ��飬����������������
			Mat est = solve_wnnm(patch_group, noise_var, 2.3, 10e-16);	//��֪��Ĺ��ƣ�δ�ۺϣ�
			Mat dist = Mat(patch_num, 1, CV_64F);
			for (int i = 0; i != patch_num; ++i) dist.at<double>(i) = mps[i].distance;
			Mat deno_patch = aggregate(dist, est, 10, prs);	//��֪�Ŀ���ƣ��Ѿۺϣ�
			double rhoK = cal_rhoK(ref_patch, deno_patch, 1, noise_var);
			deno_image_double(cv::Rect(rpos, cpos, prs, pcs)) += deno_patch + (1 - rhoK)*(ref_patch - deno_patch);	//����
			number(cv::Rect(rpos, cpos, prs, pcs)) += Mat::ones(ref_patch.size(), CV_16U);
			cout<<++now<<'/'<<patch_process<<std::endl;
		}
	}

	deno_image_double /= number;	//�򵥵���ƽ��ֵ
	Mat deno_image;
	deno_image_double.convertTo(deno_image, CV_8U);	//תΪ[0, 255]�ĻҶ�ֵ
	cv::imwrite("E:/Design/denoise/test_pics/50_deno.jpg", deno_image);	//�洢ȥ����ͼ��
	
	return 0;

}

//Mat ada_boost(const Mat& image, int prs, pcs, ) {

	

//}
